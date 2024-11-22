data "aws_route53_zone" "selected" {
  name         = "vfs.va.gov."
  private_zone = true
}

resource "aws_route53_record" "web" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "${local.name}-fg.vfs.va.gov"
  type    = "A"
  
  alias {
    name                   = aws_alb.main.dns_name
    zone_id                = aws_alb.main.zone_id
    evaluate_target_health = true
  }
}

output "domain" {
    value = aws_route53_record.web.name
}