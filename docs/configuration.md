# Configuration

This page groups the module's input variables by what they configure. For the complete
auto-generated reference with types and defaults, see the
[Usage section of the README](https://github.com/infrahouse/terraform-aws-tcp-pod#usage).

## Required Variables

| Variable | Description |
|----------|-------------|
| `service_name` | Service name used in resource names, tags, and the default DNS record. |
| `ami` | Image for the EC2 instances. |
| `subnets` | Subnet ids for the load balancer. Their `map_public_ip_on_launch` flag decides the NLB scheme. |
| `backend_subnets` | Subnet ids for the EC2 instances. |
| `nlb_listener_port` | TCP port the load balancer listens on. |
| `zone_id` | Route53 zone id where the service records are created. |
| `key_pair_name` | SSH key pair name deployed to instances. Pass `null` to let the module generate a fallback key pair. |
| `userdata` | Cloud-init payload that provisions your service on the instances. |

```hcl
module "tcp-pod" {
  source  = "registry.infrahouse.com/infrahouse/tcp-pod/aws"
  version = "0.6.0"
  providers = {
    aws     = aws
    aws.dns = aws
  }

  service_name      = "mqtt"
  environment       = "production"
  ami               = data.aws_ami.ubuntu.id
  subnets           = module.vpc.subnet_public_ids
  backend_subnets   = module.vpc.subnet_private_ids
  nlb_listener_port = 8883
  zone_id           = data.aws_route53_zone.example.zone_id
  key_pair_name     = aws_key_pair.deployer.key_name
  userdata          = module.mqtt-cloud-init.userdata
}
```

!!! warning "Set `environment` explicitly"

    `environment` defaults to `development`. Always set it explicitly — it feeds resource
    tags and the Vanta production flag.

## DNS

| Variable | Default | Description |
|----------|---------|-------------|
| `dns_a_records` | `[<service_name>]` | Record names to create. An empty string means the zone apex. |
| `zone_id` | — | The hosted zone for the records. |

```hcl
  # Create mqtt.example.com and iot.example.com pointing at the NLB
  dns_a_records = ["mqtt", "iot"]
```

DNS resources use the `aws.dns` provider, so records can live in another AWS account —
see [Examples](examples.md#dns-in-a-separate-aws-account).

## Load Balancer and Health Checks

| Variable | Default | Description |
|----------|---------|-------------|
| `nlb_listener_port` | — | Port the NLB listens on. |
| `target_group_port` | listener port | Port the backend instances serve. |
| `nlb_idle_timeout` | `60` | Seconds a connection may stay idle. |
| `nlb_name_prefix` | first 6 chars of `service_name` | Name prefix for the NLB. |
| `enable_deletion_protection` | `false` | Protect the NLB from being destroyed. |
| `nlb_healthcheck_protocol` | `TCP` | Health check protocol (`TCP`, `HTTP`, `HTTPS`). |
| `nlb_healthcheck_port` | traffic port | Health check port. |
| `nlb_healthcheck_interval` | `30` | Seconds between checks. |
| `nlb_healthcheck_timeout` | `10` | Seconds before a check times out. |
| `nlb_healthcheck_healthy_threshold` | `5` | Consecutive passes to become healthy. |
| `nlb_healthcheck_uhealthy_threshold` | `2` | Consecutive failures to become unhealthy. |

If the health check port differs from the traffic port, the module automatically adds a
security group rule allowing health checks from the VPC CIDR.

## Auto Scaling Group

### Sizing

| Variable | Default | Description |
|----------|---------|-------------|
| `asg_min_size` | number of backend subnets | Minimum instances. |
| `asg_max_size` | backend subnets + 1 | Maximum instances. |
| `asg_min_elb_capacity` | `asg_min_size` | Healthy instances Terraform waits for during apply. |
| `wait_for_capacity_timeout` | `20m` | How long Terraform waits for capacity. |
| `autoscaling_target_cpu_load` | `60` | Target average CPU (%) for target-tracking autoscaling. |

### Health and Lifecycle

| Variable | Default | Description |
|----------|---------|-------------|
| `health_check_type` | `EC2` | `EC2` or `ELB`. `ELB` replaces instances that fail NLB health checks. |
| `health_check_grace_period` | `900` | Seconds before health checks start counting. |
| `max_instance_lifetime_days` | `30` | Replace instances older than this many days (0 to disable). |
| `min_healthy_percentage` | `100` | Capacity kept in service during an instance refresh. |
| `asg_min_healthy_percentage` | `100` | Lower bound of healthy instances during replacement. |
| `asg_max_healthy_percentage` | `200` | Upper bound of healthy instances during replacement. |
| `protect_from_scale_in` | `false` | Protect new instances from scale-in termination. |
| `asg_scale_in_protected_instances` | `Ignore` | Instance refresh behavior for protected instances. |
| `asg_lifecycle_hook_launching` | `false` | Create a `LAUNCHING` lifecycle hook. |
| `asg_lifecycle_hook_terminating` | `false` | Create a `TERMINATING` lifecycle hook. |
| `asg_lifecycle_hook_heartbeat_timeout` | `3600` | Seconds before a hook times out. |
| `asg_name` | generated | Explicit ASG (and launch template) name. |

### Spot Instances

Set `on_demand_base_capacity` to run the fleet on spot instances while keeping a
guaranteed on-demand base:

```hcl
  # Two on-demand instances; anything above that is spot
  on_demand_base_capacity = 2
```

## EC2 Instances

| Variable | Default | Description |
|----------|---------|-------------|
| `instance_type` | `t3.micro` | Instance type. |
| `ami` | — | Image id. |
| `root_volume_size` | `30` | Root volume size in GB. |
| `userdata` | — | Cloud-init payload. |
| `key_pair_name` | — | SSH key pair (or `null` for a generated one). |

## Security

| Variable | Default | Description |
|----------|---------|-------------|
| `ssh_cidr_block` | `null` | Extra CIDR allowed to SSH to the backends (e.g. an office range). |
| `extra_security_groups_backend` | `[]` | Additional security group ids for the instances. |

## IAM

| Variable | Default | Description |
|----------|---------|-------------|
| `instance_profile_permissions` | minimal | JSON policy document attached to the instance profile. |
| `instance_role_name` | generated | Explicit name for the instance role. |

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

## Monitoring

| Variable | Default | Description |
|----------|---------|-------------|
| `sns_topic_alarm_arn` | `null` | SNS topic for a CPU alarm (fires above 90%). No alarm is created when unset. |

## ECS Mode

| Variable | Default | Description |
|----------|---------|-------------|
| `attach_target_group_to_asg` | `true` | Set to `false` when ECS registers targets itself. |
| `target_group_type` | `instance` | Target type: `instance`, `ip`, or `alb`. |

## Tagging and Compliance

| Variable | Default | Description |
|----------|---------|-------------|
| `tags` | `{}` | Extra tags for all module resources. Changing them triggers an instance refresh. |
| `environment` | `development` | Environment name used in tags. |
| `upstream_module` | `null` | Name of the module that called this module. |
| `vanta_owner` | `null` | Email of the resource owner in Vanta. |
| `vanta_production_environments` | `["production", "prod"]` | Environments considered production in Vanta. |
| `vanta_contains_user_data` | `false` | Whether instances contain user data. |
| `vanta_contains_ephi` | `false` | Whether instances contain ePHI. |
| `vanta_description` | `null` | Description for Vanta. |
| `vanta_user_data_stored` | `null` | Type of user data stored. |
| `vanta_no_alert` | `null` | Reason the resource is out of audit scope. |
