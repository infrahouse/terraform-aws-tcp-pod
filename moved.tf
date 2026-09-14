# The listener ingress rule gained for_each when its source became configurable
# (nlb_ingress_cidr_blocks). The source used to be hardcoded to 0.0.0.0/0, so every
# existing deployment maps to that key and keeps its rule instead of recreating it.
moved {
  from = aws_vpc_security_group_ingress_rule.tcp
  to   = aws_vpc_security_group_ingress_rule.tcp["0.0.0.0/0"]
}
