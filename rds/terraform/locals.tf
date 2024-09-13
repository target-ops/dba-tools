locals {

  common_security_group_rules = {
    vpc_ingress = {
      source_security_group_id = var.sg_id
    }
  }
  common_standard_backup_retention_period_days = 7
  common_preferred_backup_window               = "05:00-06:00"
  common_preferred_maintenance_window          = "sun:10:00-sun:14:00"

  ca_cert_identifier = "rds-ca-rsa2048-g1"

  rds_docs_link = "https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Overview.DBInstance.Modifying.html \nhttps://us-west-2.console.aws.amazon.com/cloudwatch/home?region=us-west-2#alarmsV2:?~(alarmStateFilter~'ALARM)"
  dbs = {
    "${var.environment}-example1" = {
      instance_size  = "db.r6g.large",
      engine_version = "8.0.mysql_aurora.3.05.1",
      encrypted      = true,
      engine         = "aurora-mysql",
      parameters     = []
      storage_type   = "gp2"
      # Alarm when reaching 90% of maximum number of connections to the database
      max_connections_threshold    = 900
      cw_namespace                 = "RDS"
      alarm_mitigation_description = "\n Start here ${local.rds_docs_link}"
    },
    "${var.environment}-example2" = {
      instance_size                = "db.r6g.large",
      engine_version               = "8.0.mysql_aurora.3.05.1",
      encrypted                    = true,
      engine                       = "aurora-mysql",
      parameters                   = []
      storage_type                 = "gp2"
      max_connections_threshold    = 900
      cw_namespace                 = "RDS"
      alarm_mitigation_description = "\n Start here ${local.rds_docs_link}"
    },
  }
}
