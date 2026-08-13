# Examples

Common tcp-pod configurations. A complete, working example also lives in the repository's
[examples/jumphost](https://github.com/infrahouse/terraform-aws-tcp-pod/tree/main/examples/jumphost)
directory, and the integration test root module
[test_data/tcp-pod](https://github.com/infrahouse/terraform-aws-tcp-pod/tree/main/test_data/tcp-pod)
is deployed to real AWS on every CI run.

## Internet-Facing SSH Jumphost

The NLB lives in public subnets (internet-facing), instances in private subnets:

```hcl
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

Clients connect with `ssh user@jumphost.example.com`.

## Internal Service

Place the NLB in private subnets and the module creates an internal load balancer —
no other changes needed:

```hcl
module "postgres-proxy" {
  source  = "registry.infrahouse.com/infrahouse/tcp-pod/aws"
  version = "0.6.0"
  providers = {
    aws     = aws
    aws.dns = aws
  }

  service_name      = "pgbouncer"
  environment       = "production"
  ami               = data.aws_ami.ubuntu.id
  subnets           = module.vpc.subnet_private_ids # private subnets => internal NLB
  backend_subnets   = module.vpc.subnet_private_ids
  nlb_listener_port = 5432
  zone_id           = data.aws_route53_zone.internal.zone_id
  key_pair_name     = aws_key_pair.deployer.key_name
  userdata          = module.pgbouncer-cloud-init.userdata
}
```

## DNS in a Separate AWS Account

Route53 resources use the `aws.dns` provider alias, so the DNS zone can live in a
dedicated DNS account:

```hcl
provider "aws" {
  region = "us-west-2"
}

provider "aws" {
  alias  = "dns"
  region = "us-west-2"
  assume_role {
    role_arn = "arn:aws:iam::123456789012:role/dns-manager"
  }
}

module "tcp-pod" {
  source  = "registry.infrahouse.com/infrahouse/tcp-pod/aws"
  version = "0.6.0"
  providers = {
    aws     = aws
    aws.dns = aws.dns
  }
  # ...
}
```

## Multiple DNS Records

```hcl
  # Creates mqtt.example.com, iot.example.com, and a record at the zone apex
  dns_a_records = ["mqtt", "iot", ""]
```

## Spot Instances

Keep two guaranteed on-demand instances and run everything above that on spot:

```hcl
  asg_min_size            = 3
  asg_max_size            = 10
  on_demand_base_capacity = 2
```

## Custom Health Checks

Health-check an HTTP status endpoint while serving TCP traffic on another port:

```hcl
  nlb_listener_port        = 6379
  nlb_healthcheck_protocol = "HTTP"
  nlb_healthcheck_port     = 8080
```

The module automatically opens the health check port from the VPC CIDR on the backend
security group when it differs from the traffic port.

## ECS Capacity Provider

Let the module provide NLB + ASG capacity while ECS registers targets itself:

```hcl
module "ecs-pod" {
  source  = "registry.infrahouse.com/infrahouse/tcp-pod/aws"
  version = "0.6.0"
  providers = {
    aws     = aws
    aws.dns = aws
  }

  service_name               = "game-server"
  environment                = "production"
  ami                        = data.aws_ami.ecs_optimized.id
  subnets                    = module.vpc.subnet_public_ids
  backend_subnets            = module.vpc.subnet_private_ids
  nlb_listener_port          = 7777
  zone_id                    = data.aws_route53_zone.example.zone_id
  key_pair_name              = aws_key_pair.deployer.key_name
  userdata                   = module.ecs-cloud-init.userdata
  attach_target_group_to_asg = false
  target_group_type          = "ip"
}
```

Use the `target_group_arn` output to wire the target group into your ECS service's
`load_balancer` block.

## Instance Permissions

Grant the service access to what it needs — for example, reading a configuration bucket:

```hcl
data "aws_iam_policy_document" "service" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.config.arn}/*"]
  }
}

module "tcp-pod" {
  # ...
  instance_profile_permissions = data.aws_iam_policy_document.service.json
}
```

## Alerting on CPU

```hcl
resource "aws_sns_topic" "alarms" {
  name = "service-alarms"
}

module "tcp-pod" {
  # ...
  sns_topic_alarm_arn = aws_sns_topic.alarms.arn
}
```
