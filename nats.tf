resource "aws_ecs_task_definition" "nats" {
  family                   = "nats"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.nats_cpu
  memory                   = var.nats_memory

  volume {
    name = "data"
    efs_volume_configuration {
      file_system_id = aws_efs_file_system.nats.id
    }
  }

  container_definitions = jsonencode([
    {
      name        = "nats"
      image       = var.nats_image
      command     = ["-js", "-sd", "/data"]
      cpu         = var.nats_cpu
      memory      = var.nats_memory
      networkMode = "awsvpc"
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/wasmcloud"
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "nats"
        }
      }
      mountPoints = [
        {
          sourceVolume  = "data"
          containerPath = "/data"
        }
      ]
      portMappings = [
        { protocol = "tcp", containerPort = 4222, hostPort = 4222 }
      ]
    }
  ])
}

resource "aws_efs_file_system" "nats" {
  tags = {
    Name = "nats"
  }
}

resource "aws_efs_mount_target" "nats" {
  file_system_id  = aws_efs_file_system.nats.id
  subnet_id       = aws_subnet.private[0].id
  security_groups = [aws_security_group.nats_efs.id]
}

resource "aws_iam_role" "nats_infra" {
  name = "nats-infra"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ecs.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "nats_volume_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSInfrastructureRolePolicyForVolumes"
  role       = aws_iam_role.nats_infra.name
}

resource "aws_ecs_service" "nats" {
  name            = "nats"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.nats.arn
  desired_count   = var.nats_count
  launch_type     = "FARGATE"

  network_configuration {
    security_groups = [aws_security_group.nats_task.id]
    # NOTE(lxf): gotta match efs mount target
    subnets = [aws_subnet.private[0].id]
  }

  service_registries {
    registry_arn = aws_service_discovery_service.nats.arn
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.nats.id
    container_name   = "nats"
    container_port   = 4222
  }

  depends_on = [aws_lb_listener.nats, aws_iam_role_policy_attachment.ecs-task-execution-role-policy-attachment]
}

resource "aws_service_discovery_service" "nats" {
  name = "nats"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.main.id

    dns_records {
      ttl  = 60
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}

resource "aws_security_group" "nats_efs" {
  name        = "nats-efs"
  description = "nats efs security group"
  vpc_id      = aws_vpc.main.id

  ingress {
    protocol    = "tcp"
    from_port   = 2049 # nfs
    to_port     = 2049
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_security_group" "nats_task" {
  name        = "nats-task"
  description = "nats taskgroup security group"
  vpc_id      = aws_vpc.main.id

  ingress {
    protocol    = "tcp"
    from_port   = 4222
    to_port     = 4222
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "nats_public" {
  name        = "nats-public"
  description = "controls access to the NATS ALB"
  vpc_id      = aws_vpc.main.id

  ingress {
    protocol    = "tcp"
    from_port   = 4222
    to_port     = 4222
    cidr_blocks = var.nats_allowed_cidrs
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_lb" "nats" {
  name               = "nats-public"
  load_balancer_type = "network"
  subnets            = aws_subnet.public[*].id
  security_groups    = [aws_security_group.nats_public.id]
}

output "nats_lb" {
  value = aws_lb.nats.dns_name
}

resource "aws_lb_target_group" "nats" {
  name        = "nats"
  port        = 4222
  protocol    = "TCP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"
}

resource "aws_lb_listener" "nats" {
  load_balancer_arn = aws_lb.nats.id
  port              = 4222
  protocol          = "TCP"

  default_action {
    target_group_arn = aws_lb_target_group.nats.id
    type             = "forward"
  }
}
