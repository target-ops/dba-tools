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