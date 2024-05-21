# Setup the application Load balancer

resource "aws_alb" "hello_world_lb" {
    name        = "hello-world"
    load_balancer_type = "application"
    subnets         = aws_subnet.public_snet.*.id
    security_groups = [aws_security_group.lb_sg.id]

    tags = {
      Name = "hello-world-lb-tf"
    }
}

resource "aws_alb_target_group" "hello_world_lb_tg" {
    name        = "hello-world-lb"
    port        = 8080
    protocol    = "HTTP"
    vpc_id      = aws_vpc.main.id
    target_type = "ip"

    lifecycle {
      create_before_destroy = true
    }
}

# Redirect all traffic from the Load balancer to the target group
resource "aws_alb_listener" "hello_world_listener" {
  load_balancer_arn = aws_alb.hello_world_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.hello_world_lb_tg.arn
    type             = "forward"
  }
}

# Setup Cluster
resource "aws_ecs_cluster" "hello_world_cl" {
  name = "hello-world"
}

# Define task
resource "aws_ecs_task_definition" "hello_world_api_task" {
  family                   = "hello-world-api-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  runtime_platform {
    cpu_architecture        = "X86_64"
    operating_system_family = "LINUX"
  }

  container_definitions = jsonencode([
    {
      name      = "hello-world-api"
      image     = "anastzampetis/hello-world-api:latest"
      cpu       = 512
      memory    = 1024
      essential = true
      portMappings = [
        {
          containerPort = 8080
          hostPort      = 8080
          protocol      = "tcp"
        }
      ]
    }
  ])
}

# Setup ECS Service
resource "aws_ecs_service" "hello_world_api_service" {
  name            = "hello-world-api-service"
  cluster         = aws_ecs_cluster.hello_world_cl.id
  task_definition = aws_ecs_task_definition.hello_world_api_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = aws_subnet.public_snet.*.id
    security_groups  = [aws_security_group.hw_tasks_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.hello_world_lb_tg.arn
    container_name   = "hello-world-api"
    container_port   = 8080
  }

  depends_on = [aws_alb_listener.hello_world_listener]
}