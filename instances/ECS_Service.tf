resource "aws_ecs_service" "app_service" {
  name            = "my-app-service"
  cluster         = aws_ecs_cluster.my_cluster.id
  task_definition = aws_ecs_task_definition.clixx_task_def.arn

  desired_count = 2
  launch_type   = "FARGATE"
  scheduling_strategy = "REPLICA"

  network_configuration {
    subnets = aws_subnet.private[*].id
    security_groups = [aws_security_group.ecs-sg.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.clixx-retail-tg.arn
    container_name   = "clixx-retail"
    container_port   = 80
  }

  
  depends_on = [aws_lb_listener.http_listener,
           aws_lb_target_group.clixx-retail-tg
        ]
}