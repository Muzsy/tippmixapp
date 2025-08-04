variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "europe-west1"
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

