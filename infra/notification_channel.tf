resource "google_monitoring_notification_channel" "slack_channel" {
  display_name = "Slack – OddsAPI quota"
  type         = "slack"

  labels = {
    token = var.slack_webhook_url
  }
}
