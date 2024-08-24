

locals {
  db_name = "${var.environment}-example"
  dbs = {
    (local.db_name) = {
      instance_size  = "db.r6g.large",
      engine_version = "8.0.mysql_aurora.3.05.1",
      encrypted      = true,
      engine         = "aurora-mysql",
      parameters     = []
      storage_type   = "gp2"
    }
  }
  # Common RDS settings
  common_security_group_rules = {
    vpc_ingress = {
      source_security_group_id = "sg_id_here"
    }
  }
  common_standard_backup_retention_period_days = 7
  common_preferred_backup_window               = "05:00-06:00"
  common_preferred_maintenance_window          = "sun:10:00-sun:14:00"

  ca_cert_identifier = "rds-ca-rsa2048-g1"
  vpc_id             = "vpc_id_here"
}


module "rds_aurora_clusters" {
  source   = "terraform-aws-modules/rds-aurora/aws"
  version  = "9.8.0"
  for_each = local.dbs

  name           = each.key
  engine         = each.value.engine
  engine_version = each.value.engine_version
  engine_mode    = "provisioned"
  instances = {
    1 = {
      instance_class = each.value.instance_size
    }
  }
  vpc_id                            = local.vpc_id
  create_db_subnet_group            = true
  subnets                           = ["subnet_id_here"]
  security_group_rules              = local.common_security_group_rules
  backup_retention_period           = local.common_standard_backup_retention_period_days
  preferred_backup_window           = local.common_preferred_backup_window
  preferred_maintenance_window      = local.common_preferred_maintenance_window
  apply_immediately                 = true
  skip_final_snapshot               = false
  master_username                   = "master_username_here"
  manage_master_user_password       = true
  ca_cert_identifier                = local.ca_cert_identifier
  storage_encrypted                 = true
  kms_key_id                        = "kms_key_arn_here"
  storage_type                      = each.value.storage_type
  create_db_parameter_group         = true
  create_db_cluster_parameter_group = true
  auto_minor_version_upgrade        = false
  enabled_cloudwatch_logs_exports   = ["error", "slowquery"]
}
