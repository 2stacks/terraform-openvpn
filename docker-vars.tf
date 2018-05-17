## Docker Compose Version
variable "compose_ver" {
  description = "docker-compose version"
  default     = "1.21.2"
}

## MySQL Variables
variable "mysql_label" {
  description = "Container Image Version"
  default     = "5.7.22"
}

variable "mysql_root_passwd" {
  description = "Password for mysql root user"
  default     = "radius"
}

variable "mysql_user" {
  description = "Username for radius database"
  default     = "radius"
}

variable "mysql_passwd" {
  description = "Password for radius database"
  default     = "radpass"
}

variable "mysql_database" {
  description = "Password for radius database"
  default     = "radius"
}

## Freeradius Variables
variable "radius_label" {
  description = "Container Image Version"
  default     = "latest"
}

variable "mysql_host" {
  description = "Radius Host IP"
  default     = "mysql"
}

variable "radius_key" {
  description = "Radius Key"
  default     = "testing123"
}

variable "radius_clients" {
  description = "Allowed Calling Stations"
  default     = "10.0.0.0/16"
}

variable "rad_debug" {
  description = "Set to 'yes' to Enable Container Logs"
  default     = "no"
}

## OpenVPN Variables
variable "ovpn_label" {
  description = "Container Image Version"
  default     = "latest"
}

variable "radius_host" {
  description = "Radius Host IP"
  default     = "freeradius"
}

variable "dns_host1" {
  description = "Client DNS Host"
  default     = "1.1.1.1"
}

variable "dns_host2" {
  description = "Client DNS Host"
  default     = "1.0.0.1"
}

variable "ovpn_debug" {
  description = "Set to 'yes' to Enable Container Logs"
  default     = "no"
}
