# See Digital Ocean API Documentation
# @ <https://developers.digitalocean.com/documentation/v2/> 
# for determining available images, regions and sizes.

# Terraform Digital Ocean API Key
variable "do_token" {}

# 2stacks AWS API credentials
variable "aws_access_key" {}
variable "aws_secret_key" {}

# CloudInit Variables
variable "user_name" {}
variable "user_passwd" {}
variable "ssh_authorized-key" {}

# Digital Ocean SSH Keys
variable "do_ssh_keys" {}

# Directory of additional container configs
variable "project_dir" {
  description = "Docker Project Directory"
  default     = "/opt/project-k"
}

# Default OS Images
variable "image" {
  description = "Default LTS"
  default     = "ubuntu-16-04-x64"
}

# Default Region Name
variable "region" {
  description = "Region in which to create Droplet"
  default     = "nyc3"
}

# Number of nodes to create
variable "node_count" {
    description = "Number of droplets to create"
    default     = 1
}
