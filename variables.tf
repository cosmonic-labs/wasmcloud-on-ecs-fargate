variable "aws_region" {
  description = "The AWS region things are created in"
  type        = string
}

variable "aws_profile" {
  description = "AWS Profile"
  type        = string
}

variable "az_count" {
  description = "Number of AZs to cover in a given region"
  type        = number
  default     = 2
}

## NATS
variable "nats_image" {
  description = "NATS.io Docker Image"
  type        = string
  default     = "nats:2-alpine"
}

variable "nats_count" {
  description = "Number of docker containers to run"
  type        = number
  default     = 1
}


variable "nats_cpu" {
  description = "Fargate instance CPU units to provision (1 vCPU = 1024 CPU units)"
  type        = number
  default     = 1024
}

variable "nats_memory" {
  description = "Fargate instance memory to provision (in MiB)"
  type        = number
  default     = 2048
}

variable "nats_allowed_cidrs" {
  description = "CIDR blocks to allow access to NATS LB"
  type        = list(string)
  default     = []
}

## WADM

variable "wadm_image" {
  description = "WADM Docker Image"
  type        = string
  default     = "ghcr.io/wasmcloud/wadm:v0.17.0"
}

variable "wadm_count" {
  description = "Number of docker containers to run"
  type        = number
  default     = 1
}

variable "wadm_cpu" {
  description = "Fargate instance CPU units to provision (1 vCPU = 1024 CPU units)"
  type        = number
  default     = 1024
}

variable "wadm_memory" {
  description = "Fargate instance memory to provision (in MiB)"
  type        = number
  default     = 2048
}

## WASMCLOUD

variable "wasmcloud_image" {
  description = "Wasmcloud Docker Image"
  type        = string
  default     = "ghcr.io/wasmcloud/wasmcloud:1.3.1"
}

variable "wasmcloud_workload_min_count" {
  description = "Minimum number of workload tasks to run"
  type        = number
  default     = 1
}

variable "wasmcloud_workload_max_count" {
  description = "Max number of workload tasks to run"
  type        = number
  default     = 1
}

variable "wasmcloud_public_ingress_count" {
  description = "Number of ingress tasks to run"
  type        = number
  default     = 1
}

variable "wasmcloud_cpu" {
  description = "Fargate instance CPU units to provision (1 vCPU = 1024 CPU units)"
  type        = number
  default     = 1024
}

variable "wasmcloud_memory" {
  description = "Fargate instance memory to provision (in MiB)"
  type        = number
  default     = 2048
}

variable "wasmcloud_allowed_cidrs" {
  description = "CIDR blocks to allow access to NATS LB"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}
