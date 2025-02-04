resource "aws_security_group" "nlb" {
  description = "Load balancer security group for service ${var.service_name}"
  name_prefix = "${var.service_name}-"
  vpc_id      = data.aws_subnet.selected.vpc_id
  tags = merge(
    local.default_module_tags,
    {
      Name : "${var.service_name} load balancer"
    },
    {
      VantaContainsUserData : false
      VantaContainsEPHI : false
    }
  )
}

resource "aws_vpc_security_group_ingress_rule" "tcp" {
  description       = "User traffic to TCP port"
  security_group_id = aws_security_group.nlb.id
  from_port         = var.nlb_listener_port
  to_port           = var.nlb_listener_port
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
  tags = merge(
    local.default_module_tags,
    {
      Name = "TCP user traffic"
    },
    {
      VantaContainsUserData : false
      VantaContainsEPHI : false
    }
  )
}

resource "aws_vpc_security_group_ingress_rule" "nlb_icmp" {
  description       = "Allow all ICMP traffic"
  security_group_id = aws_security_group.nlb.id
  from_port         = -1
  to_port           = -1
  ip_protocol       = "icmp"
  cidr_ipv4         = "0.0.0.0/0"
  tags = merge(
    local.default_module_tags,
    {
      Name = "ICMP traffic"
    },
    {
      VantaContainsUserData : false
      VantaContainsEPHI : false
    }
  )
}


resource "aws_vpc_security_group_egress_rule" "nlb_outgoing" {
  security_group_id = aws_security_group.nlb.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
  tags = merge(
    local.default_module_tags,
    {
      Name = "outgoing traffic"
    },
    {
      VantaContainsUserData : false
      VantaContainsEPHI : false
    }
  )
}
