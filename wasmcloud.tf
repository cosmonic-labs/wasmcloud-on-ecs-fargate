resource "aws_ecs_task_definition" "wasmcloud_workload" {
  family                   = "wasmcloud-workload"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.wasmcloud_cpu
  memory                   = var.wasmcloud_memory
  container_definitions = jsonencode([
    {
      name        = "wasmcloud"
      image       = var.wasmcloud_image
      cpu         = var.wasmcloud_cpu
      memory      = var.wasmcloud_memory
      networkMode = "awsvpc"
      essential   = true
      environment = [
        { name = "WASMCLOUD_NATS_HOST", value = "nats.cluster.wasmcloud" },
        { name = "WASMCLOUD_STRUCTURED_LOGGING_ENABLED", value = "true" },
        { name = "WASMCLOUD_LABEL_role", value = "workload" }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/wasmcloud"
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "workload"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "wasmcloud_workload" {
  name            = "wasmcloud-workload"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.wasmcloud_workload.arn
  desired_count   = var.wasmcloud_workload_count
  launch_type     = "FARGATE"

  network_configuration {
    security_groups = [aws_security_group.wasmcloud_workload.id]
    subnets         = aws_subnet.private.*.id
  }

  depends_on = [aws_iam_role_policy_attachment.ecs-task-execution-role-policy-attachment]
}


resource "aws_security_group" "wasmcloud_workload" {
  name        = "wasmcloud-workload"
  description = "wasmcloud workload security group"
  vpc_id      = aws_vpc.main.id

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

## Ingress
resource "aws_ecs_task_definition" "wasmcloud_ingress" {
  family                   = "wasmcloud-ingress"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.wasmcloud_cpu
  memory                   = var.wasmcloud_memory

  container_definitions = jsonencode([
    {
      name        = "wasmcloud"
      image       = var.wasmcloud_image
      cpu         = var.wasmcloud_cpu
      memory      = var.wasmcloud_memory
      networkMode = "awsvpc"
      essential   = true
      environment = [
        { name = "WASMCLOUD_NATS_HOST", value = "nats.cluster.wasmcloud" },
        { name = "WASMCLOUD_STRUCTURED_LOGGING_ENABLED", value = "true" },
        { name = "WASMCLOUD_LABEL_role", value = "ingress" }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/wasmcloud"
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ingress"
        }
      }
      portMappings = [
        { protocol = "tcp", containerPort = 8080, hostPort = 8080 }
      ]
    }
  ])
}

resource "aws_ecs_service" "wasmcloud_ingress" {
  name            = "wasmcloud-ingress"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.wasmcloud_ingress.arn
  desired_count   = var.wasmcloud_public_ingress_count
  launch_type     = "FARGATE"

  network_configuration {
    security_groups = [aws_security_group.wasmcloud_ingress.id]
    subnets         = aws_subnet.private.*.id
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.wasmcloud_public.id
    container_name   = "wasmcloud"
    container_port   = 8080
  }


  depends_on = [aws_lb_listener.wasmcloud_public, aws_iam_role_policy_attachment.ecs-task-execution-role-policy-attachment]
}


resource "aws_security_group" "wasmcloud_ingress" {
  name        = "wasmcloud-ingress"
  description = "wasmcloud public ingress security group"
  vpc_id      = aws_vpc.main.id

  ingress {
    protocol = "tcp"
    # NOTE(lxf): All non-privileged ports
    from_port   = 1024
    to_port     = 65535
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "wasmcloud_public" {
  name        = "wasmcloud-public"
  description = "controls access to Wasmcloud Ingress ALB"
  vpc_id      = aws_vpc.main.id

  ingress {
    protocol    = "tcp"
    from_port   = 1024
    to_port     = 65535
    cidr_blocks = var.wasmcloud_allowed_cidrs
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "wasmcloud_public" {
  name               = "wasmcloud-public"
  load_balancer_type = "network"
  subnets            = aws_subnet.public[*].id
  security_groups    = [aws_security_group.wasmcloud_public.id]
}

# NOTE(lxf): Each exposed port needs a target group / listener
resource "aws_lb_target_group" "wasmcloud_public" {
  name        = "wasmcloud"
  port        = 8080
  protocol    = "TCP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"
}

resource "aws_lb_listener" "wasmcloud_public" {
  load_balancer_arn = aws_lb.wasmcloud_public.id
  port              = 8080
  protocol          = "TCP"

  default_action {
    target_group_arn = aws_lb_target_group.wasmcloud_public.id
    type             = "forward"
  }
}
