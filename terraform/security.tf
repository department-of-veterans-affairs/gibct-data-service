resource "aws_security_group" "lb" {
    name        = "${local.name}-load-balancer-security-group"
    description = "controls access to the ALB"
    vpc_id      = data.aws_vpc.selected.id

    ingress {
        protocol    = "tcp"
        from_port   = 80
        to_port     = 80
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        protocol    = "tcp"
        from_port   = 443
        to_port     = 443
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        protocol    = "-1"
        from_port   = 0
        to_port     = 0
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_security_group" "ecs_tasks" {
    name        = "${local.name}-ecs-tasks-security-group"
    description = "allow inbound access from the ALB only"
    vpc_id      = data.aws_vpc.selected.id

    ingress {
        protocol        = "tcp"
        from_port       = 80
        to_port         = 80
        cidr_blocks = ["0.0.0.0/0"]
        # security_groups = [aws_security_group.lb.id]
    }

    ingress {
        protocol        = "tcp"
        from_port       = 443
        to_port         = 443
        cidr_blocks = ["0.0.0.0/0"]
        # security_groups = [aws_security_group.lb.id]
    }

    egress {
        protocol    = "-1"
        from_port   = 0
        to_port     = 0
        cidr_blocks = ["0.0.0.0/0"]
    }
}
