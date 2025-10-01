resource "aws_cloudwatch_log_group" "ecs_logs" {
  name              = "/ecs/clixx-retail"
  retention_in_days = 7
}

resource "aws_ecs_task_definition" "clixx_task_def" {
  family                   = "clixx_task_def"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  cpu    = "256"
  memory = "512"

  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn      = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "clixx-retail"

      # Full ECR image URI
      image = "${aws_ecr_repository.clixx_retail_repository.repository_url}:latest"
      
      essential = true

      portMappings = [
        {
          containerPort = 80
          protocol      = "tcp"
        }
      ]

      # Normal environment variables
      environment = [

        {
          name  = "DB_NAME"
          value = "wordpressdb"
        },
        {
          name  = "DB_USER"
          value = "admin"
        },
        {
          name  = "DB_PASSWORD"
          value = "Steady3203#"
        },
        {
          name  = "DB_HOST"
          value = "clixx-retaildb-restore.c5m0yi8ikbzk.us-east-2.rds.amazonaws.com"
        }
      ]

    #   # Secrets from Secrets Manager
    #   secrets = [
    #     {
    #       name      = "DB_USERNAME"
    #       valueFrom = aws_secretsmanager_secret.db_username.arn
    #     },
    #     {
    #       name      = "DB_PASSWORD"
    #       valueFrom = aws_secretsmanager_secret.db_password.arn
    #     }
    #   ]

      logConfiguration = {
        logDriver = "awslogs"

        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs_logs.name
          awslogs-region        = "us-east-2"
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}