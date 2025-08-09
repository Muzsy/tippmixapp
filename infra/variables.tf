variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "europe-central2"
}

variable "environment" {
  description = "Deployment environment (dev/prod)"
  type        = string
  default     = "dev"
}

variable "kickoff_cron" {
  description = "Cron for kickoff tracker job"
  type        = string
}
variable "poll_cron" {
  description = "Cron for result poller job"
  type        = string
}
variable "sweep_cron" {
  description = "Cron for final sweep job"
  type        = string
}


variable "slack_webhook_url" {
  type        = string
  description = "Slack Bot User OAuth token (xoxb-…)"
  default     = ""
  # Leave empty in dev to disable Slack notification channel
}

variable "quota_warn_at" {
  description = "Alert threshold for remaining OddsAPI credits"
  type        = number
  default     = 1000
}

