locals {
  default_module_tags = {
    environment : var.environment
    service : var.service_name
    account : data.aws_caller_identity.current.account_id
    created_by_module : "infrahouse/tcp-pod/aws"

  }
  default_asg_tags = merge(
    {
      Name : "tcp"
    },
    local.default_module_tags
  )
  access_log_tags = var.nlb_access_log_enabled ? {
    access_log_bucket : aws_s3_bucket.access_log[0].bucket
    access_log_bucket_policy : aws_s3_bucket_policy.access_logs[0].id
  } : {}
  min_elb_capacity = var.asg_min_elb_capacity != null ? var.asg_min_elb_capacity : var.asg_min_size
  # See https://docs.aws.amazon.com/elasticloadbalancing/latest/application/enable-access-logging.html
  elb_account_map = {
    "us-east-1" : "127311923021"
    "us-east-2" : "033677994240"
    "us-west-1" : "027434742980"
    "us-west-2" : "797873946194"

  }
}
