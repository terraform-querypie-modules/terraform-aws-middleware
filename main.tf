locals {
  type                    = var.type
  vpc_id                  = var.vpc_id
  subnet_ids              = compact(var.subnet_ids)
  security_group_ids      = compact(var.security_group_ids)
  api_url                 = var.api_url
  cpu                     = var.cpu
  memory                  = var.memory
  port                    = var.port
  cluster_id              = var.cluster_id
  task_execute_role_arn   = var.task_execute_role_arn
  image_pull_secret_arn   = var.image_pull_secret_arn
  application_credentials = var.application_credentials
  image                   = var.image
  proxy_image             = var.proxy_image
  redis_host              = var.redis_host
  log_group_name          = var.log_group_name
}

module "ecs" {
  source             = "./modules/ecs"
  vpc_id             = local.vpc_id
  security_group_ids = local.security_group_ids
  subnet_ids         = local.subnet_ids
  count              = local.type == "ecs" ? 1 : 0

  api_url                 = local.api_url
  cluster_id              = local.cluster_id
  port                    = local.port
  task_execute_role_arn   = local.task_execute_role_arn
  image_pull_secret_arn   = local.image_pull_secret_arn
  application_credentials = local.application_credentials
  image                   = local.image
  proxy_image             = local.proxy_image
  redis_host              = local.redis_host
  log_group_name          = local.log_group_name
}

module "ec2" {
  source             = "./modules/ec2"
  vpc_id             = local.vpc_id
  security_group_ids = var.security_group_ids
  subnet_ids         = local.subnet_ids
  count              = local.type == "ec2" ? 1 : 0
}