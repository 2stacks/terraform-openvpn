# This module creates one or more Digital Ocean droplets, uploads project code,
# installs Docker using docker-machine, installs Docker-Compose and adds DNS entry
# to AWS Route53

resource "digitalocean_droplet" "do-node" {
  # Obtain your ssh_key *.id number via your account. See Document https://developers.digitalocean.com/documentation/v2/#list-all-keys
  ssh_keys           = ["${var.ssh_keys}"]
  image              = "${var.image}"
  region             = "${var.region}"
  size               = "${var.size}"
  private_networking = "${var.private_networking}"
  backups            = "${var.backups}"
  ipv6               = "${var.ipv6}"
  name               = "${format("${var.region}-${var.node_type}-%02d", count.index + 1)}"
  user_data          = "${var.user_data}"
  tags               = ["${var.tags}"]

  # This will create X instances
  count = "${var.node_count}"

  connection {
    type        = "ssh"
    private_key = "${file("~/.ssh/do_rsa")}"
    user        = "root"
    timeout     = "2m"
  }

  provisioner "remote-exec" {
    inline = [
      "export PATH=$PATH:/usr/bin",
      "apt-get update",
      "DEBIAN_FRONTEND=noninteractive apt-get -y upgrade",
      "mkdir -p ${var.project_dir}",
      "curl -L https://github.com/docker/compose/releases/download/${var.compose_ver}/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose && chmod +x /usr/local/bin/docker-compose",
    ]
  }

  # Copies the configs folder to ${var.project_dir}
  provisioner "file" {
    source      = "${var.project_dir}/configs"
    destination = "${var.project_dir}"
  }

  provisioner "local-exec" {
    command = "docker-machine create --driver generic --generic-ip-address=${self.ipv4_address} --generic-ssh-key ~/.ssh/do_rsa --generic-ssh-user=root ${format("${var.region}-${var.node_type}-%02d", count.index + 1)}"
  }

  provisioner "local-exec" {
    when = "destroy"
    command = "docker-machine rm -f ${format("${var.region}-${var.node_type}-%02d", count.index + 1)}"
  }
}

resource "aws_route53_record" "do-node-dns" {
  zone_id = "${var.zone_id}"
  name    = "${format("${var.region}-${var.node_type}-%02d", count.index + 1)}.${var.zone_name}"
  type    = "${var.record_type}"
  ttl     = "${var.record_ttl}"
  records = ["${digitalocean_droplet.do-node.*.ipv4_address}"]
  count   = "${var.node_count}"
}
