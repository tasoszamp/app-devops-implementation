output "load_balancer_dns_name" {
  value = aws_alb.hello_world_lb.dns_name
}