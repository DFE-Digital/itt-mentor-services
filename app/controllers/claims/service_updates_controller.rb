class Claims::ServiceUpdatesController < Claims::ApplicationController
  skip_before_action :authenticate_user!
  before_action :skip_authorization

  def index
    @service_updates = MarkdownDocument.from_directory(Rails.root.join("app/views/claims/service_updates/content"))
      .reject { |document| document["date"].future? }
      .sort_by { |document| document["date"] }
      .reverse
  end
end
