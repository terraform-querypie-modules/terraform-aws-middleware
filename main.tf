locals {
  name           = "middleware"
  ecs_cluster_id = var.ecs_cluster_id
  cpu            = var.cpu
  memory         = var.memory

  url        = "dockerpie.querypie.com"
  repository = "chequer.io/nginx"
  nginx_tag        = "1.19.8-ecs"
  app_tag = format("querypie-app:%s", var.middleware_version)
}

resource "aws_ecs_task_definition" "this" {
  container_definitions = jsonencode(
    [
      {
        name      = "nginx"
        image     = format("%s/%s/%s", local.url, local.repository, local.nginx_tag)
        cpu       = local.cpu
        memory    = local.memory
        essential = true
      },
      {
        name   = "middleware"
        image  = format("%s/%s/%s", local.url, local.repository, local.nginx_tag)
        cpu       = local.cpu
        memory    = local.memory
        secrets = [{
          name      = "redis_password",
          valueFrom = "arn:aws:secretsmanager:region:aws_account_id:secret:appauthexample-AbCdEf:{}::"
        }]
        environment = [
          { name = url, value = 2 },
        ]
      }
    ]
  )
  family = "middleware"
}

resource "aws_ecs_service" "this" {
  name = local.name

  cluster = local.ecs_cluster_id
}