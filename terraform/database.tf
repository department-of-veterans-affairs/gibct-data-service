# TODO - likely need to define our own subnet group
data "aws_db_subnet_group" "database" {
  name = "dsva-vagov-postgres-db-sng"
}

resource "aws_rds_cluster" "this" {
  backup_retention_period       = "7"
  cluster_identifier            = "dsva-gids-${var.env_name}"
  copy_tags_to_snapshot         = true
  database_name                 = "dsva_gids_${var.env_name}"
  db_subnet_group_name          = data.aws_db_subnet_group.database.name
  deletion_protection           = true
  engine                        = "aurora-postgresql"
  engine_mode                   = "provisioned"
  engine_version                = "14.4"
  master_password               = "must_be_eight_characters" # TODO - use `manage_master_user_password` instead?
  master_username               = "gibct-data-service"
  port                          = "5432"
  preferred_backup_window       = var.preferred_backup_window
  preferred_maintenance_window  = var.preferred_maintenance_window
  skip_final_snapshot           = true
  vpc_security_group_ids        = [aws_security_group.this.id]

  serverlessv2_scaling_configuration {
    max_capacity = 1.0
    min_capacity = 0.5
  }

  tags = merge(
    var.base_tags,
    {
      "Name"        = "dsva-gids-${var.env_name}-db"
      "application" = "gi-bill-data-service"
    },
  )
}

resource "aws_rds_cluster_instance" "this" {
  cluster_identifier = aws_rds_cluster.this.id
  instance_class     = "db.serverless"
  engine             = aws_rds_cluster.this.engine
  engine_version     = aws_rds_cluster.this.engine_version
  db_subnet_group_name = data.aws_db_subnet_group.database.name
}

resource "aws_security_group" "this" {
  name        = "dsva-gids-${var.env_name}-db-sg"
  description = "Allow DB access from EKS cluster"
  vpc_id      = var.vpc_id

  ingress {
    description      = "Access to DB from EKS cluster"
    from_port        = 5432
    to_port          = 5432
    protocol         = "tcp"
    security_groups  = [module.eks_cluster.security_group_id]
  }

  tags = merge(
    var.base_tags,
    {
      "Name"        = "dsva-gids-${var.env_name}-db-sg"
      "application" = "gi-bill-data-service"
    },
  )
}