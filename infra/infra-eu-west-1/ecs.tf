ecs_cluster.tf
resource "aws_ecs_cluster" "this" {
  name = "${local.name}-cluster"
}

resource "aws_iam_role" "task_execution" {
  name = "${local.name}-task-exec"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "ecs-tasks.amazonaws.com" },
      Action   = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "task_exec_policy" {
  role       = aws_iam_role.task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_task_definition" "app" {
  family                   = "${local.name}-task"
  cpu                      = "512"
  memory                   = "1024"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.task_execution.arn

  container_definitions = jsonencode([
    {
      name  = "app",
      image = local.image_uri,
      essential = true,
      portMappings = [
        { containerPort = var.container_port, hostPort = var.container_port, protocol = "tcp" }
      ],
      environment = [
        { name = "SERVER_ADDRESS", value = "0.0.0.0" },
        { name = "JAVA_TOOL_OPTIONS", value = "-XX:MaxRAMPercentage=75 -XX:+ExitOnOutOfMemoryError" },
        # Use embedded DB by default for stability; switch to Aurora later.
        { name = "SPRING_PROFILES_ACTIVE", value = "prod" }
      ],
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group         = aws_cloudwatch_log_group.app.name,
          awslogs-region        = var.region,
          awslogs-stream-prefix = "ecs"
        }
      },
      healthCheck = {
        command     = ["CMD-SHELL", "curl -fsS http://localhost:${var.container_port}/actuator/health || exit 1"],
        interval    = 15,
        timeout     = 5,
        retries     = 3,
        startPeriod = 30
      }
    }
  ])
}

resource "aws_ecs_service" "svc" {
  name            = "${local.name}-svc"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  health_check_grace_period_seconds = 120

  network_configuration {
    assign_public_ip = false
    security_groups  = [aws_security_group.app.id]
    subnets          = [aws_subnet.private_a.id, aws_subnet.private_b.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.tg.arn
    container_name   = "app"
    container_port   = var.container_port
  }

  depends_on = [aws_lb_listener.http]
}
