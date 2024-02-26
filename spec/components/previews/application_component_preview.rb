require "factory_bot"

class ApplicationComponentPreview < ViewComponent::Preview
  include Rails.application.routes.url_helpers
end
