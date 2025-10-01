locals {
  environment = "development"
}
module "jumphost-cloud-init" {
  source                   = "registry.infrahouse.com/infrahouse/cloud-init/aws"
  version                  = "2.2.2"
  environment              = local.environment
  role                     = "jumphost"
  puppet_hiera_config_path = "/opt/infrahouse-puppet-data/environments/${local.environment}/hiera.yaml"
  packages = [
    "infrahouse-puppet-data"
  ]
}

module "lb" {
  source = "../../"
  providers = {
    aws     = aws
    aws.dns = aws
  }
  service_name                 = "jumphost"
  dns_a_records                = ["jumphost-tcp-pod"]
  subnets                      = var.lb_subnet_ids
  backend_subnets              = var.backend_subnet_ids
  ami                          = data.aws_ami.ubuntu.id
  nlb_listener_port            = 22
  zone_id                      = data.aws_route53_zone.tcp.zone_id
  key_pair_name                = aws_key_pair.test.key_name
  userdata                     = module.jumphost-cloud-init.userdata
  instance_profile_permissions = data.aws_iam_policy_document.permissions.json
  instance_role_name           = var.instance_role_name
}
