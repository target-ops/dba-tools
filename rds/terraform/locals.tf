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
      # Alarm when reaching 90% of maximum number of connections to the database
      max_connections_threshold = 900
      cw_namespace              = "RDS"
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