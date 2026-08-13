variable "region" {
  type        = string
  description = "AWS region to deploy the jumphost in."
}

variable "environment" {
  type        = string
  description = "Environment name (development, staging, production, etc.)"
  default     = "development"
}

variable "dns_zone" {
  type        = string
  description = "Existing Route53 zone name where the jumphost A record will be created."
}

variable "lb_subnet_ids" {
  type        = list(string)
  description = "Subnet ids for the load balancer. Public subnets produce an internet-facing NLB."
}

variable "backend_subnet_ids" {
  type        = list(string)
  description = "Subnet ids for the jumphost EC2 instances."
}
