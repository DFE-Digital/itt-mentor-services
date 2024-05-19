class Claims::ApplicationSlackNotifier < ApplicationSlackNotifier
  self.service = :claims
  self.endpoint_url = ENV["CLAIMS_SLACK_WEBHOOK_URL"]
end
