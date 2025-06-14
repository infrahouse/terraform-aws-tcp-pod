resource "aws_autoscaling_group" "tcp" {
  name                      = var.asg_name
  name_prefix               = var.asg_name == null ? aws_launch_template.tcp.name_prefix : null
  min_size                  = local.asg_min_size
  max_size                  = var.asg_max_size != null ? var.asg_max_size : length(var.backend_subnets) + 1
  min_elb_capacity          = local.min_elb_capacity
  vpc_zone_identifier       = var.backend_subnets
  health_check_type         = var.health_check_type
  wait_for_capacity_timeout = var.wait_for_capacity_timeout
  max_instance_lifetime     = var.max_instance_lifetime_days * 24 * 3600
  health_check_grace_period = var.health_check_grace_period
  protect_from_scale_in     = var.protect_from_scale_in
  target_group_arns         = var.target_group_type == "instance" && var.attach_target_group_to_asg ? [aws_lb_target_group.tcp.arn] : []
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage       = var.min_healthy_percentage
      scale_in_protected_instances = var.asg_scale_in_protected_instances
    }
    triggers = ["tag"]
  }
  dynamic "launch_template" {
    for_each = var.on_demand_base_capacity == null ? [1] : []
    content {
      id      = aws_launch_template.tcp.id
      version = aws_launch_template.tcp.latest_version
    }
  }
  dynamic "mixed_instances_policy" {
    for_each = var.on_demand_base_capacity == null ? [] : [1]
    content {
      instances_distribution {
        on_demand_base_capacity                  = var.on_demand_base_capacity
        on_demand_percentage_above_base_capacity = 0
      }
      launch_template {
        launch_template_specification {
          launch_template_id = aws_launch_template.tcp.id
          version            = aws_launch_template.tcp.latest_version
        }
      }
    }
  }
  instance_maintenance_policy {
    min_healthy_percentage = var.asg_min_healthy_percentage
    max_healthy_percentage = var.asg_max_healthy_percentage
  }
  dynamic "tag" {
    for_each = local.default_asg_tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true

    }
  }
  lifecycle {
    create_before_destroy = true
  }
  depends_on = [
    aws_security_group.backend
  ]
}

resource "aws_launch_template" "tcp" {
  name          = var.asg_name
  name_prefix   = var.asg_name == null ? local.nlb_name_prefix : null
  image_id      = var.ami
  instance_type = var.instance_type
  user_data     = var.userdata
  key_name      = var.key_pair_name != null ? var.key_pair_name : aws_key_pair.default.key_name
  vpc_security_group_ids = concat(
    [aws_security_group.backend.id],
    var.extra_security_groups_backend
  )
  iam_instance_profile {
    arn = module.instance_profile.instance_profile_arn
  }
  metadata_options {
    http_tokens   = "required"
    http_endpoint = "enabled"
  }
  block_device_mappings {
    device_name = data.aws_ami.selected.root_device_name
    ebs {
      volume_size           = var.root_volume_size
      delete_on_termination = true
    }
  }
  tag_specifications {
    resource_type = "volume"
    tags = merge(
      data.aws_default_tags.provider.tags,
      local.default_module_tags
    )
  }
  tag_specifications {
    resource_type = "network-interface"
    tags = merge(
      data.aws_default_tags.provider.tags,
      local.default_module_tags,
      {
        VantaContainsUserData : false
        VantaContainsEPHI : false
      }
    )
  }
  lifecycle {
    create_before_destroy = true
  }

}

resource "aws_autoscaling_lifecycle_hook" "launching" {
  count                  = var.asg_lifecycle_hook_launching == true ? 1 : 0
  name                   = "launching"
  heartbeat_timeout      = var.asg_lifecycle_hook_heartbeat_timeout
  autoscaling_group_name = aws_autoscaling_group.tcp.name
  lifecycle_transition   = "autoscaling:EC2_INSTANCE_LAUNCHING"
}

resource "aws_autoscaling_lifecycle_hook" "terminating" {
  count                  = var.asg_lifecycle_hook_terminating == true ? 1 : 0
  name                   = "terminating"
  heartbeat_timeout      = var.asg_lifecycle_hook_heartbeat_timeout
  autoscaling_group_name = aws_autoscaling_group.tcp.name
  lifecycle_transition   = "autoscaling:EC2_INSTANCE_TERMINATING"
}
