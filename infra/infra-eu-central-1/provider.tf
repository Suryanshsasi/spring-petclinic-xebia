providers.tf
variable "region" {
  type = string
}

terraform {
  backend "s3" {}
}

provider "aws" {
  region = var.region
}
