resource "aws_kms_key" "rds" {
  description             = "KMS key for RDS encryption"
  deletion_window_in_days = 10
  multi_region            = true
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
  vpc_id                            = var.vpc_id
  create_db_subnet_group            = true
  subnets                           = [var.subnet_id]
  security_group_rules              = local.common_security_group_rules
  backup_retention_period           = local.common_standard_backup_retention_period_days
  preferred_backup_window           = local.common_preferred_backup_window
  preferred_maintenance_window      = local.common_preferred_maintenance_window
  apply_immediately                 = true
  skip_final_snapshot               = false
  master_username                   = "master_username"
  manage_master_user_password       = true
  ca_cert_identifier                = local.ca_cert_identifier
  storage_encrypted                 = true
  kms_key_id                        = aws_kms_key.rds.arn
  storage_type                      = each.value.storage_type
  create_db_parameter_group         = true
  create_db_cluster_parameter_group = true
  auto_minor_version_upgrade        = false
  enabled_cloudwatch_logs_exports   = ["error", "slowquery"]
}
