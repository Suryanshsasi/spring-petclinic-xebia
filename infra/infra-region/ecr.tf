
resource "aws_ecr_repository" "repo" {
  name                 = var.ecr_repo_name
  image_tag_mutability = "IMMUTABLE"
  image_scanning_configuration { scan_on_push = true }
}

output "ecr_repo_url" {
  value = aws_ecr_repository.repo.repository_url
}
