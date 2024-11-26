module "instance_profile" {
  source       = "registry.infrahouse.com/infrahouse/instance-profile/aws"
  version      = "1.3.3"
  profile_name = "tcp-pod-profile"
  permissions  = data.aws_iam_policy_document.permissions.json
}
