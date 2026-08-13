# Getting Started

This guide walks you through deploying your first TCP service — an SSH jumphost — with the
InfraHouse tcp-pod module.

## Prerequisites

### AWS Resources

Before deploying, you need:

1. **A VPC with subnets** — subnets for the load balancer and subnets for the backend
   EC2 instances. They can be the same subnets, but a typical setup places the NLB in public
   subnets and the instances in private subnets with NAT gateway access.
2. **A Route53 hosted zone** — the module creates alias A records for your service in it.
3. **An AMI** — any image that runs your TCP service. The examples use Ubuntu.
4. **Userdata** — a cloud-init payload that installs and starts your service.
   [terraform-aws-cloud-init](https://github.com/infrahouse/terraform-aws-cloud-init)
   generates one that plays well with InfraHouse modules.

!!! tip "Public or private?"

    The module infers the NLB scheme from the **load balancer** subnets: subnets with
    `map_public_ip_on_launch = true` produce an internet-facing NLB, others an internal one.
    You don't configure the scheme explicitly.

### Providers

The module declares two AWS providers: `aws` for all service resources and `aws.dns`
for Route53 resources. This allows DNS records to live in a different AWS account.
If your DNS zone is in the same account, pass the same provider for both.

## Basic Deployment

### Step 1: Prepare the Userdata

```hcl
module "jumphost-cloud-init" {
  source  = "registry.infrahouse.com/infrahouse/cloud-init/aws"
  version = "2.2.2"

  environment = "production"
  role        = "jumphost"
}
```

### Step 2: Deploy the Module

```hcl
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}

data "aws_route53_zone" "example" {
  name = "example.com"
}

module "jumphost" {
  source  = "registry.infrahouse.com/infrahouse/tcp-pod/aws"
  version = "0.6.0"
  providers = {
    aws     = aws
    aws.dns = aws
  }

  service_name      = "jumphost"
  environment       = "production"
  ami               = data.aws_ami.ubuntu.id
  subnets           = module.vpc.subnet_public_ids
  backend_subnets   = module.vpc.subnet_private_ids
  nlb_listener_port = 22
  zone_id           = data.aws_route53_zone.example.zone_id
  key_pair_name     = aws_key_pair.deployer.key_name
  userdata          = module.jumphost-cloud-init.userdata
}
```

### Step 3: Apply and Verify

```bash
terraform init
terraform plan
terraform apply
```

Terraform waits until the Auto Scaling Group instances become healthy
(`asg_min_elb_capacity`, by default the number of backend subnets), so a successful
apply means the service is actually serving traffic.

Verify DNS and connectivity:

```bash
dig jumphost.example.com
ssh ubuntu@jumphost.example.com
```

## What Gets Created

- A Network Load Balancer with a TCP listener on `nlb_listener_port`
- A target group with health checks and source IP stickiness
- An Auto Scaling Group spanning `backend_subnets` with CPU target-tracking autoscaling
- Security groups for the NLB and the backend instances
- An IAM instance profile
- Route53 alias A record(s): by default `<service_name>.<zone name>`

## Next Steps

- [Review the architecture](architecture.md) to understand how the pieces fit together
- [Explore configuration options](configuration.md) for sizing, health checks, and scaling
- [See more examples](examples.md) including internal services and ECS mode
