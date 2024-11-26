resource "aws_security_group" "nlb" {
  description = "Load balancer security group for service ${var.service_name}"
  name_prefix = "web-"
  vpc_id      = data.aws_subnet.selected.vpc_id

  tags = merge(
    {
      Name : "${var.service_name} load balancer"
    },
    local.default_module_tags
  )
}

resource "aws_vpc_security_group_ingress_rule" "nlb_listener_port" {
  description       = "User traffic to port ${var.nlb_listener_port}"
  security_group_id = aws_security_group.nlb.id
  from_port         = var.nlb_listener_port
  to_port           = var.nlb_listener_port
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
  tags = merge(
    {
      Name = "user traffic"
    },
    local.default_module_tags
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
    {
      Name = "TCP user traffic"
    },
    local.default_module_tags
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
    {
      Name = "ICMP traffic"
    },
    local.default_module_tags
  )
}


resource "aws_vpc_security_group_egress_rule" "nlb_outgoing" {
  security_group_id = aws_security_group.nlb.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
  tags = merge(
    {
      Name = "outgoing traffic"
    },
    local.default_module_tags
  )
}