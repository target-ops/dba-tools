variable "region" {
  description = "AWS region to use."
  type        = string
}

variable "environment" {
  type        = string
  description = "The environment name."
  default     = "dev"
}

variable "team" {
  type        = string
  description = "The owner team of the deployed resources."
  default     = "devops"
}


variable "slack_webhook" {
  type        = string
  description = "The secret slack webhook to send the alarms. Not required on modifications after initial setup."
  default     = ""
}

variable "vpc_id" {
  type        = string
  description = "The VPC ID where the RDS instances will be deployed."
}

variable "subnet_id" {
  type        = string
  description = "The subnet ID where the RDS instances will be deployed."
}

variable "sg_id" {
  type        = string
  description = "The security group ID to use for the RDS instances."
}

variable "kms_key_arn" {
  type        = string
  description = "value of the KMS key ARN"
}