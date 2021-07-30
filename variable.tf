variable "type" {
  type = string
  default = null
  description = "ecs"
}

variable "vpc_id" {
  default = null
  description = "a deployed vpc id"
}

variable "ecs_cluster_id" {
  default = null
  description = "targeted ecs cluster id"
}

variable "subnet_ids" {
  type = list(string)
  default = null
  description = "a deployed subnet ids, it must be attached vpc_id"
}

variable "security_group_ids" {
  type = list(strings)
  default = null
  description = "attached security_group at querypie proxy"
}

# ============
variable "cpu" {
  type = number
  description = "container limitation of cpu"
  default = 2
}

variable "memory" {
  type = number
  description = "container limittation of memory"
  default = 4096
}

variable "middleware_version" {
  type = string
  default = null
  description = ""
}