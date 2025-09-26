locals.tf
data "aws_caller_identity" "me" {}

# Pick two AZs deterministically
data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  name     = var.app_name
  vpc_cidr = "10.70.0.0/16"

  # Subnets
  pub_a  = "10.70.101.0/24"
  pub_b  = "10.70.102.0/24"
  priv_a = "10.70.1.0/24"
  priv_b = "10.70.2.0/24"

  account_id = data.aws_caller_identity.me.account_id
  image_uri  = "${local.account_id}.dkr.ecr.${var.region}.amazonaws.com/${var.ecr_repo_name}:${var.image_tag}"
}
