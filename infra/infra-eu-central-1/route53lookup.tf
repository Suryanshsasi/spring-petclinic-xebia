data "aws_route53_zone" "root" {
  name = var.root_domain
  private_zone = false
}

locals {
  app_fqdn = "${var.app_subdomain}.${var.root_domain}"
}
