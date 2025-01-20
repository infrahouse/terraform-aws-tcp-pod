locals {
  module = "infrahouse/tcp-pod/aws"
  default_module_tags = merge(
    {
      environment : var.environment
      service : var.service_name
      account : data.aws_caller_identity.current.account_id
      created_by_module : local.module
    },
    var.upstream_module != null ? {
      upstream_module : var.upstream_module
    } : {},
    local.vanta_tags,
    var.tags
  )

  default_asg_tags = merge(
    {
      Name : var.service_name
    },
    local.default_module_tags,
    data.aws_default_tags.provider.tags,
  )

  vanta_tags = merge(
    var.vanta_owner != null ? {
      VantaOwner : var.vanta_owner
    } : {},
    {
      VantaNonProd : !contains(var.vanta_production_environments, var.environment)
      VantaContainsUserData : var.vanta_contains_user_data
      VantaContainsEPHI : var.vanta_contains_ephi
    },
    var.vanta_description != null ? {
      VantaDescription : var.vanta_description
    } : {},
    var.vanta_user_data_stored != null ? {
      VantaUserDataStored : var.vanta_user_data_stored
    } : {},
    var.vanta_no_alert != null ? {
      VantaNoAlert : var.vanta_no_alert
    } : {}
  )

  dns_a_records    = var.dns_a_records != null ? var.dns_a_records : [var.service_name]
  asg_min_size     = var.asg_min_size != null ? var.asg_min_size : length(var.backend_subnets)
  min_elb_capacity = var.asg_min_elb_capacity != null ? var.asg_min_elb_capacity : local.asg_min_size
  nlb_name_prefix  = var.nlb_name_prefix != null ? substr(var.nlb_name_prefix, 0, 6) : substr(var.service_name, 0, 6)
}
