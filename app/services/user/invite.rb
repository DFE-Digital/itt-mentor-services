class User::Invite
  include ServicePattern

  def initialize(user:, organisation:)
    @user = user
    @organisation = organisation
  end

  attr_reader :user, :organisation, :service

  def call
    return if user.service == :placements && 
      !Flipflop.enabled?(:placements_user_onboarding_emails)

    UserMailer.with(service: user.service).user_membership_created_notification(user, organisation).deliver_later
  end
end
