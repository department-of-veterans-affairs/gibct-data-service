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

      # Regular environment variables
      environment = [
        {
          name : "DEPLOYMENT_ENV"
          value : var.deployment_env
        },
        {
          name : "GIBCT_URL"
          value : var.gibct_url
        },
        {
          name : "GOVDELIVERY_STAGING_SERVICE"
          value : var.govdelivery_staging_service
        },
        {
          name : "GOVDELIVERY_URL"
          value : var.govdelivery_url
        },
        {
          name : "LINK_HOST"
          value : var.link_host
        },
        {
          name : "SANDBOX_URL"
          value : var.sandbox_url
        }
      ]

      # Parameter Store values
      secrets = [
        {
          name : "ADMIN_EMAIL"
          valueFrom : ""
        },
        {
          name : "ADMIN_PW"
          valueFrom : ""
        },
        {
          name : "GOVDELIVERY_TOKEN"
          valueFrom : "<stuff>:dsva-vagov/gibct-data-service/${var.ps_prefix}/gov_delivery_token"
        },
        {
          name : "SECRET_KEY_BASE"
          valueFrom : "<stuff>:dsva-vagov/gibct-data-service/${var.ps_prefix}/secret_key_base"
        },
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
