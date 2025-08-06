resource "google_logging_metric" "remaining_credits_metric" {
  name   = "remaining_credits"
  filter = "jsonPayload.message:\"[quota]\""
  metric_descriptor {
    metric_kind = "GAUGE"
    value_type  = "INT64"
    unit        = "1"
  }
}

resource "google_monitoring_alert_policy" "credit_low_alert" {
  display_name = "OddsAPI credits below threshold"
  combiner     = "OR"

  conditions {
    display_name = "Remaining credits low"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/remaining_credits\""
      comparison      = "COMPARISON_LT"
      threshold_value = var.quota_warn_at
      duration        = "300s" # 5 minutes
    }
  }

  notification_channels = [google_monitoring_notification_channel.slack_channel.id]
}
