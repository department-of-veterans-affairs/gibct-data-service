data "aws_subnet" "selected" {
  count = length(var.vpc_subnets)
  filter {
    name   = "tag:Name"
    values = [var.vpc_subnets[count.index]]
  }
}