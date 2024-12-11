variable "region" {}
variable "role_arn" {
  default = null
}
variable "dns_zone" {}
variable "ubuntu_codename" {}
variable "asg_name" { default = null }

variable "backend_subnet_ids" {}
variable "lb_subnet_ids" {}
variable "instance_role_name" { default = null }
