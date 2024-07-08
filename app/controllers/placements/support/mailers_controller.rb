class Placements::Support::MailersController < Placements::ApplicationController
  def index
    @previews = ActionMailer::Preview.all.filter { |preview| preview.preview_name.start_with?("placements/") }
  end
end
