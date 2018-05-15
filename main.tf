# Configure the Digital Ocean Provider
provider "digitalocean" {
  # You need to set this in your .bashrc
  # export DIGITALOCEAN_TOKEN="Your API TOKEN"
  #
  token = "${var.do_token}"
}

# Configure the AWS Provider
provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "us-east-1"
}

## Configure the Docker Provider
provider "docker" {
}

data "docker_registry_image" "docker-ovpn" {
  name = "2stacks/docker-ovpn:${var.ovpn_label}"
}

data "docker_registry_image" "freeradius" {
  name = "2stacks/freeradius:${var.radius_label}"
}

data "docker_registry_image" "mysql" {
  name = "mysql:${var.mysql_label}"
}

resource "docker_image" "docker-ovpn" {
  name          = "${data.docker_registry_image.docker-ovpn.name}"
  pull_triggers = ["${data.docker_registry_image.docker-ovpn.sha256_digest}"]
}

resource "docker_image" "freeradius" {
  name          = "${data.docker_registry_image.freeradius.name}"
  pull_triggers = ["${data.docker_registry_image.freeradius.sha256_digest}"]
}

resource "docker_image" "mysql" {
  name          = "${data.docker_registry_image.mysql.name}"
  pull_triggers = ["${data.docker_registry_image.mysql.sha256_digest}"]
}

data "template_file" "user-data" {
  template = "${file("${path.module}/templates/user-data.tpl")}"

  vars {
    user_name          = "${var.user_name}"
    user_passwd        = "${var.user_passwd}"
    ssh_authorized-key = "${var.ssh_authorized-key}"
  }
}

data "template_file" "docker-host" {
  template = "${file("${path.module}/templates/docker-compose.yml.tpl")}"

  vars {
    mysql_label       = "${var.mysql_label}"
    mysql_root_passwd = "${var.mysql_root_passwd}"
    mysql_user        = "${var.mysql_user}"
    mysql_passwd      = "${var.mysql_passwd}"
    mysql_database    = "${var.mysql_database}"
    mysql_host        = "${var.mysql_host}"
    radius_label      = "${var.radius_label}"
    radius_key        = "${var.radius_key}"
    radius_clients    = "${var.radius_clients}"
    rad_debug         = "${var.rad_debug}"
    ovpn_label        = "${var.ovpn_label}"
    radius_host       = "${var.radius_host}"
    dns_host1         = "${var.dns_host1}"
    dns_host2         = "${var.dns_host2}"
    ovpn_debug        = "${var.ovpn_debug}"
  }
}

data "aws_route53_zone" "selected" {
  name = "bsptn.xyz."
}

data "http" "my-ip" {
  url = "https://wtfismyip.com/text"
}

locals {
  node_ids        = "${concat("${module.do-node.node_id}")}"
  node_ips        = "${concat("${module.do-node.node_ipv4_address}")}"
  node_names      = "${concat("${module.do-node.node_name}")}"
}

resource "digitalocean_tag" "vpn-node" {
  name = "vpn"
}

module "do-node" {
  source      = "./modules/do_node"
  ssh_keys    = "${var.do_ssh_keys}"
  region      = "${var.do_nyc3}"
  node_count  = "${var.node_count}"
  #user_data   = "${data.template_file.user-data.rendered}"
  user_data   = ""
  node_type   = "do"
  tags        = "${digitalocean_tag.vpn-node.id}"
  zone_id     = "${data.aws_route53_zone.selected.zone_id}"
  zone_name   = "${data.aws_route53_zone.selected.name}"
  project_dir = "${var.project_dir}"
  compose_ver = "${var.compose_ver}"
}

resource "null_resource" "docker-compose" {

  # Changes to node ids or docker images requires re-provisioning
  triggers {
    node_ids     = "${join(",", local.node_ids)}"
    mysql_image  = "${docker_image.mysql.pull_triggers[0]}"
    ovpn_image   = "${docker_image.docker-ovpn.pull_triggers[0]}"
    radius_image = "${docker_image.freeradius.pull_triggers[0]}"
  }

  count = "${var.node_count}"

  connection {
    host        = "${element(local.node_ips, count.index)}"
    type        = "ssh"
    private_key = "${file("~/.ssh/do_rsa")}"
    user        = "root"
    timeout     = "2m"
  }

  provisioner "file" {
    content     = "${data.template_file.docker-host.rendered}"
    destination = "${var.project_dir}/docker-compose.yml"
  }

  provisioner "remote-exec" {
    inline = [
      "cd ${var.project_dir} && docker-compose -f docker-compose.yml up -d",
      "sleep 5",
      "rm -rf ${var.project_dir}/docker-compose.yml",
    ]
  }
}

resource "digitalocean_firewall" "default" {
  name = "Default"

  tags = ["${digitalocean_tag.vpn-node.name}"]

  inbound_rule = [
    {
      protocol           = "icmp"
      source_addresses   = ["0.0.0.0/0", "::/0"]
    },
    {
      protocol           = "tcp"
      port_range         = "22"
      source_addresses   = ["${chomp(data.http.my-ip.body)}"]
    },
    {
      protocol           = "tcp"
      port_range         = "443"
      source_addresses   = ["0.0.0.0/0", "::/0"]
    },
    {
      protocol           = "tcp"
      port_range         = "2376"
      source_addresses   = ["${chomp(data.http.my-ip.body)}"]
    },
    {
      protocol           = "udp"
      port_range         = "1194"
      source_addresses   = ["0.0.0.0/0", "::/0"]
    },
  ]

  outbound_rule = [
    {
      protocol                = "icmp"
      destination_addresses   = ["0.0.0.0/0", "::/0"]
    },
    {
      protocol                = "tcp"
      port_range              = "1-65535"
      destination_addresses   = ["0.0.0.0/0", "::/0"]
    },
    {
      protocol                = "udp"
      port_range              = "1-65535"
      destination_addresses   = ["0.0.0.0/0", "::/0"]
    },
  ]

}
