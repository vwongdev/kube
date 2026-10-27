resource "google_dns_managed_zone" "hosted_zone" {
  name     = replace(var.domain, ".", "-")
  dns_name = "${var.domain}."
}
