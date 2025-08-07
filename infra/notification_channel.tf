resource "google_monitoring_notification_channel" "slack_channel" {
  count        = var.slack_webhook_url == "" ? 0 : 1
  display_name = "Slack – OddsAPI quota"
  type         = "slack"

  labels = {
    auth_token   = var.slack_webhook_url
    channel_name = "general"
    team         = "tippmixapp"
  }
}
