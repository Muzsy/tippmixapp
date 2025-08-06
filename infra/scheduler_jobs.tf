# -------------------------------------------------
# Cloud Scheduler Jobs for result evaluation
# -------------------------------------------------

resource "google_cloud_scheduler_job" "kickoff_tracker" {
  name        = "kickoff-tracker-job"
  description = "Publishes when matches about to start"
  schedule    = var.kickoff_cron
  time_zone   = "Europe/Budapest"

  pubsub_target {
    topic_name = google_pubsub_topic.result_check.id
    data       = base64encode("{ \"job\": \"kickoff-tracker\" }")
  }
}

resource "google_cloud_scheduler_job" "result_poller" {
  name        = "result-poller-job"
  description = "Publishes periodic result polling trigger"
  schedule    = var.poll_cron
  time_zone   = "Europe/Budapest"

  pubsub_target {
    topic_name = google_pubsub_topic.result_check.id
    data       = base64encode("{ \"job\": \"result-poller\" }")
  }
}

resource "google_cloud_scheduler_job" "final_sweep" {
  name        = "final-sweep-job"
  description = "Publishes catch‑all sweep trigger"
  schedule    = var.sweep_cron
  time_zone   = "Europe/Budapest"

  pubsub_target {
    topic_name = google_pubsub_topic.result_check.id
    data       = base64encode("{ \"job\": \"final-sweep\" }")
  }
}

