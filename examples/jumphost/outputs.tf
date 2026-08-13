output "jumphost_dns_name" {
  description = "DNS name of the jumphost service."
  value       = "jumphost.${var.dns_zone}"
}

output "load_balancer_dns_name" {
  description = "DNS name of the network load balancer."
  value       = module.jumphost.load_balancer_dns_name
}

output "asg_name" {
  description = "Name of the jumphost autoscaling group."
  value       = module.jumphost.asg_name
}

output "ssh_private_key" {
  description = "Private key of the generated demo key pair."
  value       = tls_private_key.rsa.private_key_openssh
  sensitive   = true
}
