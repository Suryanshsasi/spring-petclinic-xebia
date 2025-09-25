resource "aws_rds_cluster" "main" {
  cluster_identifier = "my-cluster"
  engine            = "aurora"
  master_username   = "username"
  master_password   = "password" # Use AWS Secrets Manager for production
}
