class UserInviteService
  include ServicePattern

  def initialize(user, organisation, service)
    @user = user
    @organisation = organisation
    @service = service
  end

  attr_reader :user, :organisation, :service

  def call
    NotifyMailer.send_organisation_invite_email(user, organisation, service.to_s, url).deliver_later
  end

  private

  def url
    Rails.application.routes.url_helpers.sign_in_url(host:)
  end

  def host
    { "claims" => ENV["CLAIMS_HOST"],
      "placements" => ENV["PLACEMENTS_HOST"] }.fetch service.to_s
  end
end
