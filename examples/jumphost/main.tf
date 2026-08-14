data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

data "aws_route53_zone" "jumphost" {
  name = var.dns_zone
}

# Demo-only key pair: the private key is stored in the Terraform state.
# Pass your own key pair name in key_pair_name for real deployments.
resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "jumphost" {
  public_key = tls_private_key.rsa.public_key_openssh
}

module "jumphost-cloud-init" {
  source  = "registry.infrahouse.com/infrahouse/cloud-init/aws"
  version = "2.2.2"

  environment = var.environment
  role        = "jumphost"
}

module "jumphost" {
  source  = "registry.infrahouse.com/infrahouse/tcp-pod/aws"
  version = "1.0.0"
  providers = {
    aws     = aws
    aws.dns = aws
  }

  service_name      = "jumphost"
  environment       = var.environment
  ami               = data.aws_ami.ubuntu.id
  subnets           = var.lb_subnet_ids
  backend_subnets   = var.backend_subnet_ids
  nlb_listener_port = 22
  zone_id           = data.aws_route53_zone.jumphost.zone_id
  key_pair_name     = aws_key_pair.jumphost.key_name
  userdata          = module.jumphost-cloud-init.userdata
}
