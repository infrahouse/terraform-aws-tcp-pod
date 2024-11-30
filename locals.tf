locals {
  default_module_tags = merge(
    {
      environment : var.environment
      service : var.service_name
      account : data.aws_caller_identity.current.account_id
      created_by_module : "infrahouse/tcp-pod/aws"
    },
    var.tags
  )
  dns_a_records = var.dns_a_records != null ? var.dns_a_records : [var.service_name]
  default_asg_tags = merge(
    {
      Name : var.service_name
    },
    local.default_module_tags,
    data.aws_default_tags.provider.tags,
  )
  asg_min_size     = var.asg_min_size != null ? var.asg_min_size : length(var.backend_subnets)
  min_elb_capacity = var.asg_min_elb_capacity != null ? var.asg_min_elb_capacity : local.asg_min_size
  nlb_name_prefix  = var.nlb_name_prefix != null ? substr(var.nlb_name_prefix, 0, 6) : substr(var.service_name, 0, 6)
}
