data "aws_vpc" "selected" {
  filter {
    name   = "tag:Name"
    values = [var.vpc]
  }
}
