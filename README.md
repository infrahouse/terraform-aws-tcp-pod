# terraform-aws-tcp-pod

The module creates resources to run an TCP service in an autoscaling group.


> **Note**: Starting from version 2.0 the module separates the main aws provider and a provider for
> Route53 resources. If you don't need to separate them, just pass the same provider for `aws` and `aws.dns`
> ```hcl
> providers = {
>   aws     = aws
>   aws.dns = aws
> }
> ```

## Usage

```hcl
module "tcp" {
  providers = {
    aws     = aws.aws-uw1
    aws.dns = aws.aws-uw1
  }
  source                = "infrahouse/tcp-pod/aws"
  version               = "~> 0.1"
  environment           = var.environment
  ami                   = data.aws_ami.ubuntu_22.image_id
  backend_subnets       = module.website-vpc.subnet_private_ids
  zone_id               = "Z07662251LH3YRF2ERM3G"
  dns_a_records         = ["", "www"]
  internet_gateway_id   = module.website-vpc.internet_gateway_id
  key_pair_name         = data.aws_key_pair.aleks.key_name
  subnets               = module.website-vpc.subnet_public_ids
  userdata              = module.webserver_userdata.userdata
  stickiness_enabled    = true
}
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.11 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.6 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.11 |
| <a name="provider_aws.dns"></a> [aws.dns](#provider\_aws.dns) | ~> 5.11 |
| <a name="provider_random"></a> [random](#provider\_random) | ~> 3.6 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_instance_profile"></a> [instance\_profile](#module\_instance\_profile) | registry.infrahouse.com/infrahouse/instance-profile/aws | 1.5.1 |

## Resources

| Name | Type |
|------|------|
| [aws_autoscaling_group.tcp](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group) | resource |
| [aws_autoscaling_lifecycle_hook.launching](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_lifecycle_hook) | resource |
| [aws_autoscaling_lifecycle_hook.terminating](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_lifecycle_hook) | resource |
| [aws_autoscaling_policy.cpu_load](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_policy) | resource |
| [aws_launch_template.tcp](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template) | resource |
| [aws_lb.tcp](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |
| [aws_lb_listener.tcp](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_target_group.tcp](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_route53_record.extra](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_security_group.backend](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.nlb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_vpc_security_group_egress_rule.backend_outgoing](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_egress_rule.nlb_outgoing](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.backend_healthcheck](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.backend_icmp](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.backend_ssh_input](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.backend_ssh_local](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.backend_user_traffic](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.nlb_icmp](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.tcp](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [random_string.profile_suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [aws_ami.selected](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_default_tags.provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/default_tags) | data source |
| [aws_iam_policy_document.default_permissions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_route53_zone.webserver_zone](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |
| [aws_subnet.selected](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |
| [aws_vpc.service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ami"></a> [ami](#input\_ami) | Image for EC2 instances | `string` | n/a | yes |
| <a name="input_asg_lifecycle_hook_heartbeat_timeout"></a> [asg\_lifecycle\_hook\_heartbeat\_timeout](#input\_asg\_lifecycle\_hook\_heartbeat\_timeout) | How much time in seconds to wait until the hook is completed before proceeding with the default action. | `number` | `3600` | no |
| <a name="input_asg_lifecycle_hook_launching"></a> [asg\_lifecycle\_hook\_launching](#input\_asg\_lifecycle\_hook\_launching) | Create a LAUNCHING lifecycle hook, if True. | `bool` | `false` | no |
| <a name="input_asg_lifecycle_hook_terminating"></a> [asg\_lifecycle\_hook\_terminating](#input\_asg\_lifecycle\_hook\_terminating) | Create a TERMINATING lifecycle hook, if True. | `bool` | `false` | no |
| <a name="input_asg_max_healthy_percentage"></a> [asg\_max\_healthy\_percentage](#input\_asg\_max\_healthy\_percentage) | Specifies the upper limit on the number of instances that are in the InService or Pending state with a healthy status during an instance replacement activity. | `number` | `200` | no |
| <a name="input_asg_max_size"></a> [asg\_max\_size](#input\_asg\_max\_size) | Maximum number of instances in ASG | `number` | `10` | no |
| <a name="input_asg_min_elb_capacity"></a> [asg\_min\_elb\_capacity](#input\_asg\_min\_elb\_capacity) | Terraform will wait until this many EC2 instances in the autoscaling group become healthy. By default, it's equal to var.asg\_min\_size. | `number` | `null` | no |
| <a name="input_asg_min_healthy_percentage"></a> [asg\_min\_healthy\_percentage](#input\_asg\_min\_healthy\_percentage) | Specifies the lower limit on the number of instances that must be in the InService state with a healthy status during an instance replacement activity. | `number` | `100` | no |
| <a name="input_asg_min_size"></a> [asg\_min\_size](#input\_asg\_min\_size) | Minimum number of instances in ASG | `number` | `2` | no |
| <a name="input_asg_name"></a> [asg\_name](#input\_asg\_name) | Autoscaling group name, if provided. | `string` | `null` | no |
| <a name="input_asg_scale_in_protected_instances"></a> [asg\_scale\_in\_protected\_instances](#input\_asg\_scale\_in\_protected\_instances) | Behavior when encountering instances protected from scale in are found. Available behaviors are Refresh, Ignore, and Wait. | `string` | `"Ignore"` | no |
| <a name="input_assume_dns"></a> [assume\_dns](#input\_assume\_dns) | If True, create DNS records provided by var.dns\_a\_records. | `bool` | `true` | no |
| <a name="input_attach_tagret_group_to_asg"></a> [attach\_tagret\_group\_to\_asg](#input\_attach\_tagret\_group\_to\_asg) | By default we want to register all ASG instances in the target group. However ECS registers targets itself. Disable it if using website-pod for ECS. | `bool` | `true` | no |
| <a name="input_autoscaling_target_cpu_load"></a> [autoscaling\_target\_cpu\_load](#input\_autoscaling\_target\_cpu\_load) | Target CPU load for autoscaling | `number` | `60` | no |
| <a name="input_backend_subnets"></a> [backend\_subnets](#input\_backend\_subnets) | Subnet ids where EC2 instances should be present | `list(string)` | n/a | yes |
| <a name="input_dns_a_records"></a> [dns\_a\_records](#input\_dns\_a\_records) | List of A records in the zone\_id that will resolve to the nlb dns name. | `list(string)` | <pre>[<br/>  ""<br/>]</pre> | no |
| <a name="input_enable_deletion_protection"></a> [enable\_deletion\_protection](#input\_enable\_deletion\_protection) | Prevent load balancer from destroying | `bool` | `false` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Name of environment | `string` | `"development"` | no |
| <a name="input_extra_security_groups_backend"></a> [extra\_security\_groups\_backend](#input\_extra\_security\_groups\_backend) | A list of security group ids to assign to backend instances | `list(string)` | `[]` | no |
| <a name="input_health_check_grace_period"></a> [health\_check\_grace\_period](#input\_health\_check\_grace\_period) | ASG will wait up to this number of seconds for instance to become healthy | `number` | `600` | no |
| <a name="input_health_check_type"></a> [health\_check\_type](#input\_health\_check\_type) | Type of healthcheck the ASG uses. Can be EC2 or ELB. | `string` | `"ELB"` | no |
| <a name="input_instance_profile_permissions"></a> [instance\_profile\_permissions](#input\_instance\_profile\_permissions) | A JSON with a permissions policy document. The policy will be attached to the instance profile. | `string` | `null` | no |
| <a name="input_instance_role_name"></a> [instance\_role\_name](#input\_instance\_role\_name) | If specified, the instance profile role will have this name. Otherwise, the role name will be generated. | `string` | `null` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | EC2 instances type | `string` | `"t3.micro"` | no |
| <a name="input_internet_gateway_id"></a> [internet\_gateway\_id](#input\_internet\_gateway\_id) | Not used, but AWS Internet Gateway must be present. Ensure by passing its id. | `string` | n/a | yes |
| <a name="input_key_pair_name"></a> [key\_pair\_name](#input\_key\_pair\_name) | SSH keypair name to be deployed in EC2 instances | `string` | n/a | yes |
| <a name="input_max_instance_lifetime_days"></a> [max\_instance\_lifetime\_days](#input\_max\_instance\_lifetime\_days) | The maximum amount of time, in \_days\_, that an instance can be in service, values must be either equal to 0 or between 7 and 365 days. | `number` | `30` | no |
| <a name="input_min_healthy_percentage"></a> [min\_healthy\_percentage](#input\_min\_healthy\_percentage) | Amount of capacity in the Auto Scaling group that must remain healthy during an instance refresh to allow the operation to continue, as a percentage of the desired capacity of the Auto Scaling group. | `number` | `100` | no |
| <a name="input_nlb_healthcheck_enabled"></a> [nlb\_healthcheck\_enabled](#input\_nlb\_healthcheck\_enabled) | Whether health checks are enabled. | `bool` | `true` | no |
| <a name="input_nlb_healthcheck_healthy_threshold"></a> [nlb\_healthcheck\_healthy\_threshold](#input\_nlb\_healthcheck\_healthy\_threshold) | Number of times the host have to pass the test to be considered healthy | `number` | `2` | no |
| <a name="input_nlb_healthcheck_interval"></a> [nlb\_healthcheck\_interval](#input\_nlb\_healthcheck\_interval) | Number of seconds between checks | `number` | `5` | no |
| <a name="input_nlb_healthcheck_path"></a> [nlb\_healthcheck\_path](#input\_nlb\_healthcheck\_path) | Path on the webserver that the elb will check to determine whether the instance is healthy or not | `string` | `"/index.html"` | no |
| <a name="input_nlb_healthcheck_port"></a> [nlb\_healthcheck\_port](#input\_nlb\_healthcheck\_port) | Port of the webserver that the elb will check to determine whether the instance is healthy or not | `any` | `80` | no |
| <a name="input_nlb_healthcheck_protocol"></a> [nlb\_healthcheck\_protocol](#input\_nlb\_healthcheck\_protocol) | Protocol to use with the webserver that the elb will check to determine whether the instance is healthy or not | `string` | `"HTTP"` | no |
| <a name="input_nlb_healthcheck_response_code_matcher"></a> [nlb\_healthcheck\_response\_code\_matcher](#input\_nlb\_healthcheck\_response\_code\_matcher) | Range of http return codes that can match | `string` | `"200-299"` | no |
| <a name="input_nlb_healthcheck_timeout"></a> [nlb\_healthcheck\_timeout](#input\_nlb\_healthcheck\_timeout) | Number of seconds to timeout a check | `number` | `4` | no |
| <a name="input_nlb_healthcheck_uhealthy_threshold"></a> [nlb\_healthcheck\_uhealthy\_threshold](#input\_nlb\_healthcheck\_uhealthy\_threshold) | Number of times the host have to pass the test to be considered UNhealthy | `number` | `2` | no |
| <a name="input_nlb_idle_timeout"></a> [nlb\_idle\_timeout](#input\_nlb\_idle\_timeout) | The time in seconds that the connection is allowed to be idle. | `number` | `60` | no |
| <a name="input_nlb_listener_port"></a> [nlb\_listener\_port](#input\_nlb\_listener\_port) | TCP port that a load balancer listens. | `number` | n/a | yes |
| <a name="input_nlb_name_prefix"></a> [nlb\_name\_prefix](#input\_nlb\_name\_prefix) | Name prefix for the load balancer | `string` | `"web"` | no |
| <a name="input_protect_from_scale_in"></a> [protect\_from\_scale\_in](#input\_protect\_from\_scale\_in) | Whether newly launched instances are automatically protected from termination by Amazon EC2 Auto Scaling when scaling in. | `bool` | `false` | no |
| <a name="input_root_volume_size"></a> [root\_volume\_size](#input\_root\_volume\_size) | Root volume size in EC2 instance in Gigabytes | `number` | `30` | no |
| <a name="input_service_name"></a> [service\_name](#input\_service\_name) | Descriptive name of a service that will use this VPC | `string` | `"tcp"` | no |
| <a name="input_ssh_cidr_block"></a> [ssh\_cidr\_block](#input\_ssh\_cidr\_block) | CIDR range that is allowed to SSH into the backend instances.  Format is a.b.c.d/<prefix>. | `string` | `null` | no |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | Subnet ids where load balancer should be present | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to instances in the autoscaling group. | `map(string)` | <pre>{<br/>  "Name": "webserver"<br/>}</pre> | no |
| <a name="input_target_group_port"></a> [target\_group\_port](#input\_target\_group\_port) | TCP port that a target listens to to serve requests from the load balancer. | `number` | `80` | no |
| <a name="input_target_group_type"></a> [target\_group\_type](#input\_target\_group\_type) | Target group type: instance, ip, nlb. Default is instance. | `string` | `"instance"` | no |
| <a name="input_userdata"></a> [userdata](#input\_userdata) | userdata for cloud-init to provision EC2 instances | `string` | n/a | yes |
| <a name="input_wait_for_capacity_timeout"></a> [wait\_for\_capacity\_timeout](#input\_wait\_for\_capacity\_timeout) | How much time to wait until all instances are healthy | `string` | `"20m"` | no |
| <a name="input_zone_id"></a> [zone\_id](#input\_zone\_id) | Domain name zone ID where the website will be available | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_asg_arn"></a> [asg\_arn](#output\_asg\_arn) | ARN of the created autoscaling group |
| <a name="output_asg_name"></a> [asg\_name](#output\_asg\_name) | Name of the created autoscaling group |
| <a name="output_backend_security_group"></a> [backend\_security\_group](#output\_backend\_security\_group) | Map with security group id and rules |
| <a name="output_dns_name"></a> [dns\_name](#output\_dns\_name) | DNS name of the load balancer. |
| <a name="output_instance_profile_name"></a> [instance\_profile\_name](#output\_instance\_profile\_name) | EC2 instance profile name. |
| <a name="output_instance_role_policy_arn"></a> [instance\_role\_policy\_arn](#output\_instance\_role\_policy\_arn) | Policy ARN attached to EC2 instance profile. |
| <a name="output_instance_role_policy_attachment"></a> [instance\_role\_policy\_attachment](#output\_instance\_role\_policy\_attachment) | Policy attachment id. |
| <a name="output_instance_role_policy_name"></a> [instance\_role\_policy\_name](#output\_instance\_role\_policy\_name) | Policy name attached to EC2 instance profile. |
| <a name="output_load_balancer_arn"></a> [load\_balancer\_arn](#output\_load\_balancer\_arn) | Load Balancer ARN |
| <a name="output_load_balancer_dns_name"></a> [load\_balancer\_dns\_name](#output\_load\_balancer\_dns\_name) | Load balancer DNS name. |
| <a name="output_target_group_arn"></a> [target\_group\_arn](#output\_target\_group\_arn) | Target group ARN that listens to the service port. |
| <a name="output_zone_id"></a> [zone\_id](#output\_zone\_id) | Zone id where A records are created for the service. |
