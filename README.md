# OpenVPN with Docker and Terraform
In short this package launches an [OpenVPN](https://openvpn.net/index.php/open-source.html) stack in "the cloud" using [Terraform.io](https://www.terraform.io/).

More specifically, this package;

*   Creates a [Digital Ocean](https://www.digitalocean.com/) Droplet.
*   Deploys [Docker](https://www.docker.com/) on the Droplet using [docker-machine](https://docs.docker.com/machine/).
*   Installs [docker-compose](https://docs.docker.com/compose/) on the Droplet.
*   Uploads several container configs and a [docker-compose.yml](https://docs.docker.com/compose/compose-file/) file.
*   Launches a full OpenVPN, FreeRadius, MySQL stack.
*   Creates a Digital Ocean Firewall to secure the Droplet.
*   Registers the Droplet's name in [AWS Route53](https://aws.amazon.com/route53/).

At this time this package is highly customized for my own use.  If any interest is shown I may attempt to make it more generalized to support other cloud providers, containers, configurations etc.  At a minimum this serves as a working example of integrating Docker with Terraform.

## Prerequisites
There are many.  I will continue to improve this list and add detail as time permits.

*   Accounts and API Keys
    *   AWS (Route53)
    *   Digital Ocean
    *   Docker Hub
*   Software
    *   Terraform
    *   Docker
    *   Docker Compose
    *   Docker Machine
*   Other Stuff
    *   Secrets
    *   Container Prerequisites

## Secrets
The following required variables can be stored in a [secret.auto.tfvars](https://www.terraform.io/intro/getting-started/variables.html) file in the root directory.
```
# Terraform Digital Ocean API Key
variable "do_token" {}

# Digital Ocean SSH Keys
variable "do_ssh_keys" {}

# AWS API credentials
variable "aws_access_key" {}
variable "aws_secret_key" {}

# CloudInit Variables
variable "user_name" {}
variable "user_passwd" {}
variable "ssh_authorized-key" {}
```

## Container Prerequisites
The OpenVPN and FreeRadius containers used by this package are maintained by me and are publicly available.  Please see each containers documentation for prerequisites and dependencies.

*   docker-ovpn - <https://hub.docker.com/r/2stacks/docker-ovpn/>
*   freeradius  - <https://hub.docker.com/r/2stacks/freeradius/>
*   mysql       - <https://hub.docker.com/_/mysql/>

This package is known not to work with MySQL version 8.x due to a change in the [Preferred Authentication Plugin](https://dev.mysql.com/doc/refman/8.0/en/caching-sha2-pluggable-authentication.html) from previous versions.


## Run this example using:
```bash
terraform init
terraform plan
terraform apply
```

## Support for Terraform Workspaces
This allows creating a parallel development server for testing updates and Changes.

```bash
git branch dev
terraform workspace new dev
terraform init -upgrade
terraform plan
terraform apply
```
Note: this will create an additional server whose host name is tagged with 'dev'
