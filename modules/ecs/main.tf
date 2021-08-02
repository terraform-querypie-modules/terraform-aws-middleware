locals {
  vpc_id                = var.vpc_id
  subnet_ids            = var.subnet_ids
  image                 = var.image
  nginx_image           = var.nginx_image
  cluster_id            = var.cluster_id
  api_url               = var.api_url
  high_availability     = length(local.subnet_ids) > 2
  image_pull_secret_arn = var.image_pull_secret_arn
  cpu                   = var.cpu
  memory                = var.memory
  port                  = var.port
  task_execute_role_arn = var.task_execute_role_arn
  # network
  security_groups_ids     = var.security_group_ids
  network_mode            = "awsvpc"
  support_provider        = ["FARGATE"]
  application_credentials = var.application_credentials
  redis_host              = var.redis_host
}

resource "aws_ecs_task_definition" "this" {
  cpu                      = local.cpu
  memory                   = local.memory
  execution_role_arn       = local.task_execute_role_arn
  network_mode             = local.network_mode
  requires_compatibilities = local.support_provider
  task_role_arn            = local.task_execute_role_arn

  container_definitions = jsonencode(
    [
      {
        name  = "nginx"
        image = local.nginx_image
        repositoryCredentials = {
          credentialsParameter = local.image_pull_secret_arn
        }
        essential = true
      },
      {
        name  = "middleware"
        image = local.image
        repositoryCredentials = {
          credentialsParameter = local.image_pull_secret_arn
        }
        secrets = [{
          name      = "redis_password",
          valueFrom = format("%s:%s::", local.application_credentials, "REDIS_PASSWORD")
        }]
        environment = [
          { name = "API_URL", value = local.api_url },
          { name = "LOG_JSON_STRING", value = tostring(true) },
          { name = "NODE_ENV", value = "production" },
          { name = "PORT", value = tostring(local.port) },
          { name = "REDIS_DB", value = tostring(0) },
          { name = "REDIS_EVENTKEY", value = "ecs" },
          { name = "REDIS_HOST", value = local.redis_host },
        ]
      }
    ]
  )
  family = "middleware"
}

resource "aws_ecs_service" "this" {
  for_each = toset(local.subnet_ids)

  name            = "middleware-${trimprefix(each.key, "subnet-")}"
  cluster         = local.cluster_id
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = [each.key]
    security_groups = local.security_groups_ids
  }

  lifecycle {
    create_before_destroy = true
  }
}