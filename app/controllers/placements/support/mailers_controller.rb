class Placements::Support::MailersController < Placements::ApplicationController
  skip_after_action :verify_policy_scoped

  def index
    @previews = ActionMailer::Preview.all.filter { |preview| preview.preview_name.start_with?("placements/") }
  end
end
