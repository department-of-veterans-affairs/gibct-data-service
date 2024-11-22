resource "aws_ecs_cluster" "main" {
  name = local.name
}

data "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"
}

locals {
  def = jsonencode([
    {
      name           = local.name,
      image          = "${aws_ecr_repository.this.repository_url}:${var.app_version}"
      mountPoints    = []
      systemControls = []
      volumesFrom    = []
      essential      = true
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "${aws_cloudwatch_log_group.log_group.name}"
          awslogs-region        = "us-gov-west-1"
          awslogs-stream-prefix = "ecs"
        }
      }
      portMappings = [
        {
          hostPort      = 80
          containerPort = 80
          protocol      = "tcp"
        }
      ]
      environment = [
        # {
        #   name : "foo"
        #   value : "bar"
        # },
      ]
    }
  ])
}

resource "aws_ecs_task_definition" "app" {
  family                   = "${local.name}-app-task"
  execution_role_arn       = data.aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
  container_definitions    = local.def
  
  depends_on = [
    aws_alb_listener.web,
  ]
}

resource "aws_ecs_service" "main" {
  name            = "${local.name}-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = var.fargate_count
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [aws_security_group.ecs_tasks.id]
    subnets          = data.aws_subnet.selected.*.id
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.web.id
    container_name   = "${local.name}"
    container_port   = 80
  }

  depends_on = [
    aws_alb_listener.web,
  ]
}

resource "aws_cloudwatch_log_group" "log_group" {
  name              = "/ecs/${local.name}"
  retention_in_days = 30

  tags = {
    Name = "${local.name}-log-group"
  }
}

resource "aws_cloudwatch_log_stream" "log_stream" {
  name           = "${local.name}-log-stream"
  log_group_name = aws_cloudwatch_log_group.log_group.name
}
