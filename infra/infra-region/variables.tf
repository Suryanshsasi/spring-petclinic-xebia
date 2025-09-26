variables.tf
variable "app_name" {
  type    = string
  default = "petclinic"
}

variable "region" {
  type    = string
  default = "eu-central-1"
}

variable "container_port" {
  type    = number
  default = 8080
}

variable "desired_count" {
  type    = number
  default = 2
}

variable "ecr_repo_name" {
  type    = string
  default = "petclinic"
}

variable "image_tag" {
  type    = string
  default = "latest"
}
