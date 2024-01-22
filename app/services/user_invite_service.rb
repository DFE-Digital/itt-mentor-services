class UserInviteService
  include ServicePattern

  def initialize(user, organisation)
    @user = user
    @organisation = organisation
    @service = user.service
  end

  attr_reader :user, :organisation, :service

  def call
    NotifyMailer.send_organisation_invite_email(user, organisation, url).deliver_later
  end

  private

  def url
    Rails.application.routes.url_helpers.sign_in_url(host:)
  end

  def host
    { "claims" => ENV["CLAIMS_HOST"],
      "placements" => ENV["PLACEMENTS_HOST"] }.fetch service
  end
end
