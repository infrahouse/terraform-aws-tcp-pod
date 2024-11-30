resource "aws_route53_record" "extra" {
  provider = aws.dns
  count    = length(local.dns_a_records)
  zone_id  = var.zone_id
  name     = trimprefix(join(".", [local.dns_a_records[count.index], data.aws_route53_zone.selected.name]), ".")
  type     = "A"
  alias {
    name                   = aws_lb.tcp.dns_name
    zone_id                = aws_lb.tcp.zone_id
    evaluate_target_health = true
  }
}
