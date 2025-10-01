
# Declare the data source for availablity zone
data "aws_availability_zones" "available" {
  state = "available"
}


data "aws_vpc" "jenkins" {
  filter {
    name   = "tag:Name"
    values = ["default"]
  }
}