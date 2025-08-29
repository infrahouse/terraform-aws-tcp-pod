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

resource "aws_route53_record" "caa_amazon" {
  provider = aws.dns
  count    = var.create_caa_records ? length(local.dns_a_records) : 0
  zone_id  = var.zone_id
  name     = trimprefix(join(".", [local.dns_a_records[count.index], data.aws_route53_zone.selected.name]), ".")
  type     = "CAA"
  ttl      = 300
  records = [
    "0 issue \"amazon.com\"",
    "0 issue \"amazontrust.com\"",
    "0 issue \"awstrust.com\"",
    "0 issue \"amazonaws.com\""
  ]
}
