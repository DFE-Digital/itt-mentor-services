class Placements::ApplicationSlackNotifier < ApplicationSlackNotifier
  self.service = :placements
  self.endpoint_url = ENV["PLACEMENTS_SLACK_WEBHOOK_URL"]
end
