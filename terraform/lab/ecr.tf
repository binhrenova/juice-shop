resource "aws_ecr_repository" "juice_shop" {
  name                 = "juice-shop"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
}
