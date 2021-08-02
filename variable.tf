variable "type" {
  type        = string
  default     = null
  description = "ecs"
}

variable "vpc_id" {
  default     = null
  description = "a deployed vpc id"
}

variable "cluster_id" {
  default     = null
  description = "targeted ecs cluster id"
}

variable "subnet_ids" {
  type        = list(string)
  default     = null
  description = "a deployed subnet ids, it must be attached vpc_id"
}

variable "security_group_ids" {
  type        = list(string)
  default     = null
  description = "attached security_group at querypie proxy"
}

# ============
variable "cpu" {
  type        = number
  description = "container limitation of cpu"
  default     = 2048
}

variable "memory" {
  type        = number
  description = "container limitation of memory"
  default     = 4096
}

variable "api_url" {
  type    = string
  default = null
  validation {
    condition     = var.api_url != null
    error_message = "Make sure your input value, the conditions satisfied."
  }
}

variable "application_credentials" {
  type        = string
  default     = null
  description = "querypie application credentials"
  validation {
    condition     = var.application_credentials != null
    error_message = "Make sure your input value, the conditions satisfied."
  }
}

variable "image" {
  type        = string
  default     = "dockerpie.querypie.com/chequer.io/querypie-app:latest"
  description = "querypie middleware container image"
}

variable "nginx_image" {
  type        = string
  default     = "dockerpie.querypie.com/chequer.io/nginx:1.19.8-ecs"
  description = "querypie middleware container image"
}

variable "image_pull_secret_arn" {
  type    = string
  default = null
  validation {
    condition     = var.image_pull_secret_arn != null
    error_message = "Make sure your input value, the conditions satisfied."
  }
}

variable "task_execute_role_arn" {
  type    = string
  default = null
  validation {
    condition     = var.task_execute_role_arn != null
    error_message = "Make sure your input value, the conditions satisfied."
  }
}

variable "port" {
  type    = number
  default = 3000
}

variable "redis_host" {
  type    = string
  default = null
  validation {
    condition     = var.redis_host != null
    error_message = "Make sure your input value, the conditions satisfied."
  }
}