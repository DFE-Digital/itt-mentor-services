class Claims::Support::MailersController < Claims::Support::ApplicationController
  before_action :skip_authorization

  def index
    @previews = ActionMailer::Preview.all.filter { |preview| preview.preview_name.start_with?("claims/") }
  end
end
