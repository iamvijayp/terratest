# Create an ECS cluster
resource "aws_ecs_cluster" "bopis-engine-cluster" {
  name = "bopis-engine-cluster"
}
# Create a security group for the Fargate containers
resource "aws_security_group" "fargate" {
  name        = "fargate"
  description = "Access to the Fargate containers"
  vpc_id      = aws_vpc.main.id
}
# Allow ingress from the public ALB
resource "aws_security_group_rule" "ingress_public_alb" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.fargate.id
  source_security_group_id = aws_security_group.public_alb.id
}
# Allow ingress from other containers in the same security group
resource "aws_security_group_rule" "ingress_self" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.fargate.id
  self              = true
}

# Create a security group for the public facing load balancer
resource "aws_security_group" "public_alb" {
  name        = "public_alb"
  description = "Access to the public facing load balancer"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 8080
    to_port     = 8082
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
# Create a public facing load balancer
resource "aws_lb" "public_alb" {
  name               = "public-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.public_alb.id]
  subnets            = aws_subnet.public[*].id

#   enable_deletion_protection = true

  idle_timeout = 30

  tags = {
    Name = "public-alb"
  }
}
################ TARGET GROUPS ################
# Create a target group for the core-service
resource "aws_lb_target_group" "core_service" {
  name     = "core-service-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
}

# Create a target group for the store-service
resource "aws_lb_target_group" "store_service" {
  name     = "store-service-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
}

# Create a target group for the admin-service
resource "aws_lb_target_group" "admin_service" {
  name     = "admin-service-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
}

################ LISTENERS ################
# Create a listener for the core-service
resource "aws_lb_listener" "core_service" {
  load_balancer_arn = aws_lb.public_alb.arn
  port              = 8080
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.core_service.arn
  }
}

# Create a listener for the store-service
resource "aws_lb_listener" "store_service" {
  load_balancer_arn = aws_lb.public_alb.arn
  port              = 8081
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.store_service.arn
  }
}

# Create a listener for the admin-service
resource "aws_lb_listener" "admin_service" {
  load_balancer_arn = aws_lb.public_alb.arn
  port              = 8082
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.admin_service.arn
  }
}


# Create an IAM role for the ECS service
resource "aws_iam_role" "ecs_service" {
  name = "ecs_service"

  assume_role_policy = jsonencode({
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "ecs.amazonaws.com"
        }
      }
    ]
    Version = "2012-10-17"
  })

  inline_policy {
    name   = "ecs_service"
    policy = jsonencode({
      Statement = [
        {
          Action   = [
            "ec2:AttachNetworkInterface",
            "ec2:CreateNetworkInterface",
            "ec2:CreateNetworkInterfacePermission",
            "ec2:DeleteNetworkInterface",
            "ec2:DeleteNetworkInterfacePermission",
            "ec2:Describe*",
            "ec2:DetachNetworkInterface",
            "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
            "elasticloadbalancing:DeregisterTargets",
            "elasticloadbalancing:Describe*",
            "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
            "elasticloadbalancing:RegisterTargets"
          ]
          Effect   = "Allow"
          Resource = "*"
        }
      ]
      Version   = "2012-10-17"
    })
  }
}

# Create an IAM role for the ECS task execution
resource "aws_iam_role" "ecs_task_execution" {
  name = "ecs_task_execution"

  assume_role_policy = jsonencode({
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
    Version = "2012-10-17"
  })

  inline_policy {
    name   = "ecs_task_execution"
    policy = jsonencode({
      Statement = [
        {
          Action   = [
            "ecr:GetAuthorizationToken",
            "ecr:BatchCheckLayerAvailability",
            "ecr:GetDownloadUrlForLayer",
            "ecr:BatchGetImage",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ]
          Effect   = "Allow"
          Resource = "*"
        }
      ]
      Version   = "2012-10-17"
    })
  }
}

# Create an ECS service for the core-service
resource "aws_ecs_service" "core_service" {
  name            = "core_service"
  cluster         = aws_ecs_cluster.bopis-engine-cluster.id
  task_definition = aws_ecs_task_definition.core_service.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = aws_subnet.private[*].id
    security_groups  = [aws_security_group.fargate.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.core_service.arn
    container_name   = "core-service"
    container_port   = 80
  }

  depends_on = [aws_lb_listener.core_service]
}

# Create an ECS service for the store-service
resource "aws_ecs_service" "store_service" {
  name            = "store_service"
  cluster         = aws_ecs_cluster.bopis-engine-cluster.id
  task_definition = aws_ecs_task_definition.store_service.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = aws_subnet.private[*].id
    security_groups  = [aws_security_group.fargate.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.store_service.arn
    container_name   = "store-service"
    container_port   = 80
  }

  depends_on = [aws_lb_listener.store_service]
}

# Create an ECS service for the admin-service
resource "aws_ecs_service" "admin_service" {
  name            = "admin_service"
  cluster         = aws_ecs_cluster.bopis-engine-cluster.id
  task_definition = aws_ecs_task_definition.admin_service.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = aws_subnet.private[*].id
    security_groups  = [aws_security_group.fargate.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.admin_service.arn
    container_name   = "admin-service"
    container_port   = 80
  }

  depends_on = [aws_lb_listener.admin_service]
}


# Create an ECS task definition for the core-service
resource "aws_ecs_task_definition" "core_service" {
  family                   = "core-service"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn

  container_definitions = jsonencode([
    {
      name  = "core-service"
      image = "nginx:latest"
      portMappings = [
        {
          containerPort = 80
          hostPort      = 8080
        }
      ]
    }
  ])
}

# Create an ECS task definition for the store-service
resource "aws_ecs_task_definition" "store_service" {
  family                   = "store-service"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn

  container_definitions = jsonencode([
    {
      name  = "store-service"
      image = "httpd:latest"
      portMappings = [
        {
          containerPort = 80
          hostPort      = 8081
        }
      ]
    }
  ])
}

# Create an ECS task definition for the admin-service
resource "aws_ecs_task_definition" "admin_service" {
  family                   = "admin-service"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn

  container_definitions = jsonencode([
    {
      name  = "admin-service"
      image = "httpd:alpine"
      portMappings = [
        {
          containerPort = 80
          hostPort      = 8082
        }
      ]
    }
  ])
}
