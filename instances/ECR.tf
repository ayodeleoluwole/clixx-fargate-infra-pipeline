resource "aws_ecr_repository" "clixx_retail_repository" {
  name                 = "clixx_retail_repository"
  image_tag_mutability = "MUTABLE"

  force_delete = true

  image_scanning_configuration {
    scan_on_push = true
  }
}