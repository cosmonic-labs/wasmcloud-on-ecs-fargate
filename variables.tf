# variables.tf

variable "aws_region" {
  description = "The AWS region things are created in"
}

variable "aws_profile" {
  description = "AWS Profile"
}

variable "ec2_task_execution_role_name" {
  description = "ECS task execution role name"
  default     = "myEcsTaskExecutionRole"
}

variable "ecs_auto_scale_role_name" {
  description = "ECS auto scale role name"
  default     = "myEcsAutoScaleRole"
}

variable "az_count" {
  description = "Number of AZs to cover in a given region"
  default     = "2"
}

## NATS
variable "nats_image" {
  description = "NATS.io Docker Image"
  default     = "nats:2-alpine"
}

variable "nats_volume_size" {
  description = "EBS Volume size in GB"
  default     = 10
}

variable "nats_count" {
  description = "Number of docker containers to run"
  default     = 1
}


variable "nats_cpu" {
  description = "Fargate instance CPU units to provision (1 vCPU = 1024 CPU units)"
  default     = 1024
}

variable "nats_memory" {
  description = "Fargate instance memory to provision (in MiB)"
  default     = 2048
}

variable "nats_allowed_cidrs" {
  description = "CIDR blocks to allow access to NATS LB"
  default     = []
}

## WADM

variable "wadm_image" {
  description = "WADM Docker Image"
  default     = "ghcr.io/wasmcloud/wadm:v0.17.0"
}

variable "wadm_count" {
  description = "Number of docker containers to run"
  default     = 1
}

variable "wadm_cpu" {
  description = "Fargate instance CPU units to provision (1 vCPU = 1024 CPU units)"
  default     = 1024
}

variable "wadm_memory" {
  description = "Fargate instance memory to provision (in MiB)"
  default     = 2048
}

## WASMCLOUD

variable "wasmcloud_image" {
  description = "Wasmcloud Docker Image"
  default     = "ghcr.io/wasmcloud/wasmcloud:1.3.1"
}

variable "wasmcloud_workload_min_count" {
  description = "Minimum number of workload tasks to run"
  default     = 1
}

variable "wasmcloud_workload_max_count" {
  description = "Max number of workload tasks to run"
  default     = 1
}

variable "wasmcloud_public_ingress_count" {
  description = "Number of ingress tasks to run"
  default     = 1
}

variable "wasmcloud_cpu" {
  description = "Fargate instance CPU units to provision (1 vCPU = 1024 CPU units)"
  default     = 1024
}

variable "wasmcloud_memory" {
  description = "Fargate instance memory to provision (in MiB)"
  default     = 2048
}

variable "wasmcloud_allowed_cidrs" {
  description = "CIDR blocks to allow access to NATS LB"
  default     = ["0.0.0.0/0"]
}
