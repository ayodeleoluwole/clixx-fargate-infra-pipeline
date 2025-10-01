# Create the Application Load Balancer (ALB)
resource "aws_lb" "clixx-retail-lb" {
  name                      = "clixx-retail-lb"
  internal                  = false
  load_balancer_type        = "application"
  security_groups           = [aws_security_group.alb-sg.id]   
  subnets                   = aws_subnet.public[*].id
  enable_deletion_protection = false # Set to true in production

  tags = {
    Name        = "Clixxretail-SB-Server"
    OwnerEmail  = "ayodeleoluwole112@gmail.com"
    StackTeam   = "stackcloud9"
    Schedule    = "A"
    Backup      = "Yes"
  }
}


# Create a Target Group
resource "aws_lb_target_group" "clixx-retail-tg" {
  name     = "clixx-retail-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.myapp-vpc.id
  target_type = "ip"

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Environment = "Development"
  }
}



# Create an HTTP Listener for the ALB
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.clixx-retail-lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.clixx-retail-tg.arn
  }
}

