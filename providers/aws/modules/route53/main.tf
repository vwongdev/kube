resource "aws_route53_zone" "hosted_zone" {
  name = var.domain
}

resource "aws_acm_certificate" "cert" {
  domain_name       = var.domain
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "validation" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.hosted_zone.zone_id
}

resource "aws_acm_certificate_validation" "cert_verify" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.validation : record.fqdn]

  lifecycle {
    precondition {
      # Checks if the NS records for the domain match the delegation set of the hosted zone.
      # Prevents certificate validation from hanging indefinitely if the NS delegation is not setup.
      condition = alltrue([
        for ns in aws_route53_zone.hosted_zone.name_servers :
        can(regex(ns, data.external.actual_ns.result.nameservers))
      ])
      error_message = "CRITICAL: The Nameservers at your registrar do not match the new Route 53 Zone. ACM validation will hang. Please update registrar to: ${join(", ", aws_route53_zone.hosted_zone.name_servers)}"
    }
  }
}

data "external" "actual_ns" {
  program = [
    "sh", 
    "-c", 
    "echo \"{\\\"nameservers\\\": \\\"$(dig +short NS ${aws_route53_zone.hosted_zone.name} | tr '\\n' ',' | sed 's/,$//')\\\"}\""
  ]
}