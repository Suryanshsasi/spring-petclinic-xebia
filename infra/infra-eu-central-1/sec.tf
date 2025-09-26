security_groups.tf
# ALB SG: open 80 to the world
resource "aws_security_group" "alb" {
  name        = "${local.name}-alb-sg"
  description = "ALB ingress"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# App SG: only ALB can reach container port
resource "aws_security_group" "app" {
  name        = "${local.name}-app-sg"
  description = "ECS tasks receive from ALB"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port       = var.container_port
    to_port         = var.container_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
