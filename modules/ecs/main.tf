locals {
  vpc_id                = var.vpc_id
  subnet_ids            = var.subnet_ids
  image                 = var.image
  proxy_image           = var.proxy_image
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
  log_group_name          = var.log_group_name
  proxy_name              = "nginx"
  application_name        = "middleware"
  log_driver              = "awslogs"
}
# get current region
data "aws_region" "current" {}
# get cluster_default_logging_group
data "aws_cloudwatch_log_group" "this" {
  name = local.log_group_name
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
        name  = local.proxy_name
        image = local.proxy_image
        repositoryCredentials = {
          credentialsParameter = local.image_pull_secret_arn
        }
        essential = true
      },
      {
        name  = local.application_name
        image = local.image
        repositoryCredentials = {
          credentialsParameter = local.image_pull_secret_arn
        }
        secrets = [{
          name      = "REDIS_PASSWORD",
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
        logConfiguration = {
          logDriver = local.log_driver
          options = {
            awslogs-group         = data.aws_cloudwatch_log_group.this.name
            awslogs-region        = data.aws_region.current.name
            awslogs-stream-prefix = local.application_name
          }
        }
      }
    ]
  )
  family = local.application_name
}

resource "aws_ecs_service" "this" {
  for_each = toset(local.subnet_ids)

  name            = format("%s-%s", local.application_name, trimprefix(each.key, "subnet-"))
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