output "vpc_id" {
  value = aws_vpc.myapp-vpc.id
}

output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}

output "alb_sg_id" {
  value = aws_security_group.alb-sg.id
}

output "ecs_sg_id" {
  value = aws_security_group.ecs-sg.id
}


output "ecr_repository_url" {
  value = aws_ecr_repository.clixx_retail_repository.repository_url
}


output "ecs_execution_role_arn" {
  value = aws_iam_role.ecs_task_execution_role.arn
}

output "rds_sg_id" {
  value = aws_security_group.rds-sg.id
}

output "db_subnet_group_name" {
  value = aws_db_subnet_group.db_subnet.name
}

output "lb_endpoint" {
  description = "The DNS name of the load balancer"
  value       = aws_lb.clixx-retail-lb.dns_name
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.my_cluster.name
}

output "ecs_service_name" {
  value = aws_ecs_service.app_service.name
}