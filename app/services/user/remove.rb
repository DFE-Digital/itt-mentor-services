class User::Remove
  include ServicePattern

  def initialize(user:, organisation:)
    @user = user
    @organisation = organisation
  end

  attr_reader :user, :organisation

  def call
    user_membership.destroy!
    return unless user.service == :claims ||
      Flipflop.enabled?(:user_onboarding_emails)

    UserMailer.with(service: user.service).user_membership_destroyed_notification(user, organisation).deliver_later
  end

  private

  def user_membership
    @user_membership ||= user.user_memberships.find_by!(organisation:)
  end
end
