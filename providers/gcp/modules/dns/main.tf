resource "google_dns_managed_zone" "hosted_zone" {
  name     = replace(var.domain, ".", "-")
  dns_name = "${var.domain}."
}

resource "google_compute_managed_ssl_certificate" "cert" {
  name = "${replace(var.domain, ".", "-")}-cert"

  managed {
    domains = [var.domain]
  }

  lifecycle {
    create_before_destroy = true

    precondition {
      # Checks if the NS records for the domain match the name servers of the hosted zone.
      # Prevents the certificate from staying in provisioning indefinitely if the NS delegation is not setup.
      condition = alltrue([
        for ns in google_dns_managed_zone.hosted_zone.name_servers :
        can(regex(ns, data.external.actual_ns.result.nameservers))
      ])
      error_message = "CRITICAL: The Nameservers at your registrar do not match the new Cloud DNS Zone. Certificate provisioning will hang. Please update registrar to: ${join(", ", google_dns_managed_zone.hosted_zone.name_servers)}"
    }
  }
}

data "external" "actual_ns" {
  program = [
    "sh",
    "-c",
    "echo \"{\\\"nameservers\\\": \\\"$(dig +short NS ${var.domain} | tr '\\n' ',' | sed 's/,$//')\\\"}\""
  ]
}
