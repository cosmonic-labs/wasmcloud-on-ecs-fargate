resource "aws_ecs_cluster" "main" {
  name = "wasmcloud"
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_service_discovery_private_dns_namespace" "main" {
  name        = "cluster.wasmcloud"
  description = "wasmcloud"
  vpc         = aws_vpc.main.id
}

