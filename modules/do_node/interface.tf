variable "ssh_keys" {
  description = "DO SSH Key used for Provisioning"
}

variable "project_dir" {
  description = "Docker Project Directory"
}

variable "image" {
  description = "DO SSH Key used for Provisioning"
  default     = "ubuntu-16-04-x64"
}

variable "region" {
  description = "DO Region"
}

variable "size" {
  description = "DO instance size"
  default     = "512mb"
}

variable "private_networking" {
  description = "Enable Private Networking"
  default     = false
}

variable "backups" {
  description = "Enable Backups"
  default     = false
}

variable "ipv6" {
  description = "Enable IPv6"
  default     = false
}

variable "node_type" {
  description = "Type of Node"
}

variable "node_count" {
  description = "Number of nodes to create"
}

variable "user_data" {
  description = "Cloud Init User Data"
}

variable "tags" {
  description = "Tags to apply to Nodes"
}

variable "compose_ver" {
    description = "docker-compose version"
}

variable "zone_id" {
  description = "DNS Domain Zone ID"
}

variable "zone_name" {
  description = "DNS Domain Name"
}

variable "record_type" {
  description = "Type of DNS Record to add"
  default     = "A"
}

variable "record_ttl" {
  description = "TTL set on Record"
  default     = "300"
}

output "node_id" {
  value = "${digitalocean_droplet.do-node.*.id}"
}

output "node_ipv4_address" {
  value = "${digitalocean_droplet.do-node.*.ipv4_address}"
}

output "node_name" {
  value = "${digitalocean_droplet.do-node.*.name}"
}
