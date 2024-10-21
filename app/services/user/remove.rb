class User::Remove < ApplicationService
  def initialize(user:, organisation:)
    @user = user
    @organisation = organisation
  end

  attr_reader :user, :organisation

  def call
    user_membership.destroy!
    user_mailer_class(user).user_membership_destroyed_notification(user, organisation).deliver_later
  end

  private

  def user_membership
    @user_membership ||= user.user_memberships.find_by!(organisation:)
  end

  def user_mailer_class(user)
    if user.service == :claims
      Claims::UserMailer
    else
      Placements::SchoolUserMailer
    end
  end
end
