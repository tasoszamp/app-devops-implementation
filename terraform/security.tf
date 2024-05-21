# Allow access to the Load Balancer
resource "aws_security_group" "lb_sg" {
    name        = "load-balancer"
    description = "Allow public access to the Load Balancer"
    vpc_id      = aws_vpc.main.id

    ingress {
        protocol    = "tcp"
        from_port   = 80
        to_port     = 80
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        protocol    = "-1"
        from_port   = 0
        to_port     = 0
        cidr_blocks = ["0.0.0.0/0"]
    }
}

# ECS Cluster access only through the Load Balancer
resource "aws_security_group" "hw_tasks_sg" {
    name        = "hello-world-tasks"
    description = "Only allow inbound traffic from Load Balancer"
    vpc_id      = aws_vpc.main.id

    ingress {
        protocol        = "tcp"
        from_port       = 8080
        to_port         = 8080
        security_groups = [aws_security_group.lb_sg.id]
    }

    egress {
        protocol    = "-1"
        from_port   = 0
        to_port     = 0
        cidr_blocks = ["0.0.0.0/0"]
    }
}