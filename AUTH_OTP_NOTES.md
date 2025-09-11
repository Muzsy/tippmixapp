# OTP Email Verification – Supabase Notes

- Confirm signup email template should include only the verification code token: `{{ .Token }}`.
- Do not include `{{ .ConfirmationURL }}`; the app verifies code via Supabase Auth `verifyOTP`.
- Recommended: mention code validity duration and retry cooldown in template body.

