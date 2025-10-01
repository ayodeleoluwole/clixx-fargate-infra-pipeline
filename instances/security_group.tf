
#========================================================================
# Application load balancer security group
#========================================================================

resource "aws_security_group" "alb-sg" {
  vpc_id     = aws_vpc.myapp-vpc.id
  name       = "ALB-SG"
  description = "Load balancer Security Group to receive http and https requests"

  # Inbound HTTP from internet
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  # Inbound HTTPS from internet
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound to everywhere (ALB needs to reach EC2 instances on their listener/health check ports)
  egress {
    protocol      = "-1"
    from_port     = 0
    to_port       = 0
    cidr_blocks   = ["0.0.0.0/0"]
  }
}


#========================================================================
# ECS instance security group
#========================================================================
resource "aws_security_group" "ecs-sg" {
  vpc_id     = aws_vpc.myapp-vpc.id
  name       = "ECS-SG"
  description = "Allow HTTP traffic ONLY from the ALB security group"


  # Inbound HTTP from application load balancer listening on port 80
  ingress {
    security_groups = [aws_security_group.alb-sg.id]    #Instead of using cidr_cidr_blocks =  ["0.0.0.0/0"] whch allows traffic from the internet
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"  
  }


  # Inbound HTTP from application load balancer
  egress {
    protocol      = "-1"
    from_port     = 0
    to_port       = 0
    cidr_blocks   = ["0.0.0.0/0"]
  }

}



#========================================================================
# RDS security group
#========================================================================
resource "aws_security_group" "rds-sg" {
  vpc_id     = aws_vpc.myapp-vpc.id
  name       = "RDS-SG"
  description = "Allow RDS traffic from EC2 SG only"


  # Allow ECS (port 3306) traffic ONLY from the EC2 security group0
  ingress {
    security_groups = [aws_security_group.ecs-sg.id]    #Instead of receiving traffuc from cidr_cidr_blocks =  ["0.0.0.0/0"] whch allows traffic from the internet
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"  
  }


    # Allow Jenkins server to connect to RDS on port 3306.
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.jenkins.cidr_block]
    description = "Allow MySQL from Jenkins VPC"
  }

  

  # Default egress to allow all outbound traffic
  egress {
    protocol      = "-1"
    from_port     = 0
    to_port       = 0
    cidr_blocks   = ["0.0.0.0/0"]
  }

}



