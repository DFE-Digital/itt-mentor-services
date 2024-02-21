class User::Remove
  include ServicePattern

  def initialize(user:, organisation:)
    @user = user
    @organisation = organisation
  end

  attr_reader :user, :organisation

  def call
    user_membership.destroy!

    UserMailer.with(service: user.service).user_removal_notification(user, organisation).deliver_later
  end

  private

  def user_membership
    @user_membership ||= user.user_memberships.find_by!(organisation:)
  end
end
