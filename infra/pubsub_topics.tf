terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# -------------------------------------------------
# Pub/Sub Topics for result evaluation pipeline
# -------------------------------------------------

resource "google_pubsub_topic" "result_check" {
  name                       = "result-check"
  message_retention_duration = "604800s" # 7 days
  labels = {
    env = var.environment
  }
}

resource "google_pubsub_topic" "result_check_dlq" {
  name                       = "result-check-dlq"
  message_retention_duration = "604800s"
  labels = {
    env = var.environment
  }
}
