variable "env_name" {
    type    = string
}

variable "preferred_backup_window" {
    type    = string
    default = "00:00-01:00"
}

variable "preferred_maintenance_window" {
    type    = string
    default = "tue:10:01-tue:10:31"
}

variable "vpc_id" {
    type    = string
}
