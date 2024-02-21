class User::Invite
  include ServicePattern

  def initialize(user:, organisation:)
    @user = user
    @organisation = organisation
  end

  attr_reader :user, :organisation, :service

  def call
    UserMailer.with(service: user.service).user_invitation_notification(user, organisation).deliver_later
  end
end
