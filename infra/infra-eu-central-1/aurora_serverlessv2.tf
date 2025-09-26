# DB subnets: reuse your private subnets
resource "aws_db_subnet_group" "db" {
  name = "${var.app_name}-dbsubnets"
  subnet_ids = [aws_subnet.private_a.id, aws_subnet.private_b.id]
}

# DB Security Group: allow MySQL from app SG
resource "aws_security_group" "db" {
  name = "${var.app_name}-db-sg"
  description = "Aurora from ECS app"
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    security_groups = [aws_security_group.app.id]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Aurora MySQL Serverless v2 cluster
resource "aws_rds_cluster" "aurora" {
  engine = "aurora-mysql"
  engine_mode = "provisioned"
  database_name = var.db_name
  master_username = var.db_username
  master_password = var.db_password
  db_subnet_group_name = aws_db_subnet_group.db.name
  vpc_security_group_ids = [aws_security_group.db.id]
  serverlessv2_scaling_configuration {
    min_capacity = var.min_acu
    max_capacity = var.max_acu
  }
  deletion_protection = false
}

resource "aws_rds_cluster_instance" "writer" {
  cluster_identifier = aws_rds_cluster.aurora.id
  engine = "aurora-mysql"
  instance_class = "db.serverless"
}

output "aurora_writer_endpoint" { value = aws_rds_cluster.aurora.endpoint }
output "aurora_reader_endpoint" { value = aws_rds_cluster.aurora.reader_endpoint }
