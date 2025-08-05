# ⏱️ OddsAPI kvótafigyelő (HU)

Ez a dokumentum bemutatja azokat a Terraform erőforrásokat, amelyek figyelik a megmaradt OddsAPI krediteket és Slack értesítést küldenek, ha a szint túl alacsony.

## Terraform
- `infra/monitoring_alert.tf` hozza létre a `remaining_credits` log-metrikát és a `credit_low_alert` szabályt.
- `infra/notification_channel.tf` konfigurálja a Slack értesítési csatornát.

## Környezeti változók
- `QUOTA_WARN_AT` – riasztási küszöb a megmaradt kreditekre.
- `SLACK_WEBHOOK_URL` – a Slack csatorna WebHook URL-je.
