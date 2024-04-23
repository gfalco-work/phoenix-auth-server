########################################################################################################################
## AWS credentials
########################################################################################################################

variable "region" {
  description = "AWS region"
  default     = "eu-west-2"
  type        = string
}
########################################################################################################################
## Service variables
########################################################################################################################

variable "namespace" {
  description = "Namespace for resource names"
  default     = "phoenix"
  type        = string
}

variable "environment" {
  description = "Environment for deployment (like dev or staging)"
  default     = "dev"
  type        = string
}

variable "scenario" {
  description = "Scenario name for tags"
  default     = "ecs-ec2"
  type        = string
}

# for example inventory service
variable "service_name" {
  description = "A Docker image-compatible name for the service"
  default     = "inventory"
  type        = string
}

# variable "domain_name" {
#   description = "Domain name of the service (like service.example.com)"
#   type        = string
# }

########################################################################################################################
## Cloudwatch
########################################################################################################################

variable "retention_in_days" {
  description = "Retention period for Cloudwatch logs"
  default     = 7
  type        = number
}

########################################################################################################################
## Network variables
########################################################################################################################

variable "az_count" {
  description = "Describes how many availability zones are used"
  default     = 2
  type        = number
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC network"
  default     = "10.1.0.0/16"
  type        = string
}

########################################################################################################################
## ALB
########################################################################################################################

variable "custom_origin_host_header" {
  description = "Custom header to ensure communication only through CloudFront"
  default     = "Demo123"
  type        = string
}

variable "healthcheck_endpoint" {
  description = "Endpoint for ALB healthcheck"
  type        = string
  default     = "/"
}

variable "healthcheck_matcher" {
  description = "HTTP status code matcher for healthcheck"
  type        = string
  default     = "200"
}

########################################################################################################################
## EC2 Computing variables
########################################################################################################################

# variable "public_ec2_key" {
#   description = "Public key for SSH access to EC2 instances"
#   type        = string
# }
#
# variable "instance_type" {
#   description = "Instance type for EC2"
#   default     = "t3.micro"
#   type        = string
# }

########################################################################################################################
## ECR
########################################################################################################################

# variable "ecr_force_delete" {
#   description = "Forces deletion of Docker images before resource is destroyed"
#   default     = true
#   type        = bool
# }
#
# variable "hash" {
#   description = "Task hash that simulates a unique version for every new deployment of the ECS Task"
#   type        = string
# }

########################################################################################################################
## ECS variables
########################################################################################################################

variable "ecs_task_desired_count" {
  description = "How many ECS tasks should run in parallel"
  default     = 2
  type        = number
}

variable "ecs_task_min_count" {
  description = "How many ECS tasks should minimally run in parallel"
  default     = 2
  type        = number
}

variable "ecs_task_max_count" {
  description = "How many ECS tasks should maximally run in parallel"
  default     = 10
  type        = number
}

variable "ecs_task_deployment_minimum_healthy_percent" {
  description = "How many percent of a service must be running to still execute a safe deployment"
  default     = 50
  type        = number
}

variable "ecs_task_deployment_maximum_percent" {
  description = "How many additional tasks are allowed to run (in percent) while a deployment is executed"
  default     = 100
  type        = number
}

variable "cpu_target_tracking_desired_value" {
  description = "Target tracking for CPU usage in %"
  default     = 70
  type        = number
}

variable "memory_target_tracking_desired_value" {
  description = "Target tracking for memory usage in %"
  default     = 80
  type        = number
}

variable "maximum_scaling_step_size" {
  description = "Maximum amount of EC2 instances that should be added on scale-out"
  default     = 5
  type        = number
}

variable "minimum_scaling_step_size" {
  description = "Minimum amount of EC2 instances that should be added on scale-out"
  default     = 1
  type        = number
}

variable "target_capacity" {
  description = "Amount of resources of container instances that should be used for task placement in %"
  default     = 100
  type        = number
}

variable "container_port" {
  description = "Port of the container"
  type        = number
  default     = 3000
}

variable "cpu_units" {
  description = "Amount of CPU units for a single ECS task"
  default     = 100
  type        = number
}

variable "memory" {
  description = "Amount of memory in MB for a single ECS task"
  default     = 256
  type        = number
}

