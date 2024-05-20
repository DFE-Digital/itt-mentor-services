class ApplicationSlackNotifier < SlackNotifier
  include Rails.application.routes.url_helpers

  class_attribute :service

  private

  def default_url_options
    { host:, port: ENV["PORT"] }
  end

  def host
    case service.to_s
    when "claims"
      ENV["CLAIMS_HOST"]
    when "placements"
      ENV["PLACEMENTS_HOST"]
    end
  end
end
