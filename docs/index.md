# InfraHouse tcp-pod

This Terraform module runs a TCP service in an EC2 Auto Scaling Group behind a Network Load
Balancer (NLB), with Route53 alias records pointing at the NLB.

Use it for any plain TCP protocol — SSH jumphosts, databases, mail servers, message brokers —
anything that isn't HTTP. For HTTP services, see
[terraform-aws-website-pod](https://github.com/infrahouse/terraform-aws-website-pod).

## Why This Module?

Most load balancer modules focus on HTTP services behind an Application Load Balancer.
This module is built for TCP services and packages everything a production service needs:

- **Complete service pod**: NLB, listener, target group, Auto Scaling Group, launch template,
  security groups, instance profile, SSH key pair, and DNS records — in one module.
- **Split-account DNS**: a dedicated `aws.dns` provider alias lets Route53 records live
  in a different AWS account than the service.
- **Scheme inferred, not configured**: public load balancer subnets produce an internet-facing
  NLB, private subnets an internal one.
- **Safe rolling updates**: tag changes trigger a rolling instance refresh with configurable
  healthy percentage limits.
- **ECS-ready**: the target group can be detached from the ASG so ECS can register targets itself.
- **Compliance built-in**: resources carry Vanta compliance tags and resource provenance tags.

## Features

- Network Load Balancer with a TCP listener and configurable health checks
- EC2 Auto Scaling Group with CPU target-tracking autoscaling
- Route53 alias A records for the service (one or many)
- Internet-facing or internal scheme inferred from subnet configuration
- Security groups for the NLB and backend instances following least privilege
- Optional SSH access rule and generated fallback SSH key pair
- Instance profile with default or caller-supplied IAM permissions
- Spot instance support with configurable on-demand base capacity
- Optional ASG lifecycle hooks for launch and termination
- Optional CloudWatch CPU alarm publishing to an SNS topic
- Supports AWS provider version 6

## Quick Start

```hcl
module "tcp-pod" {
  source  = "registry.infrahouse.com/infrahouse/tcp-pod/aws"
  version = "1.0.0"
  providers = {
    aws     = aws
    aws.dns = aws
  }

  # Required
  service_name      = "jumphost"
  environment       = "production"
  ami               = data.aws_ami.ubuntu.id
  subnets           = module.vpc.subnet_public_ids
  backend_subnets   = module.vpc.subnet_private_ids
  nlb_listener_port = 22
  zone_id           = data.aws_route53_zone.example.zone_id
  key_pair_name     = aws_key_pair.deployer.key_name
  userdata          = module.cloud-init.userdata
}
```

## Documentation

- [Getting Started](getting-started.md) — Prerequisites and first deployment
- [Architecture](architecture.md) — How the module works
- [Configuration](configuration.md) — All available options
- [Examples](examples.md) — Common use cases
- [Troubleshooting](troubleshooting.md) — Common issues and solutions
- [Changelog](changelog.md) — Release history
