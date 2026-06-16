class User::Invite < ApplicationService
  def initialize(user:, organisation:)
    @user = user
    @organisation = organisation
  end

  attr_reader :user, :organisation

  def call
    user_mailer_class.user_membership_created_notification(user, organisation).deliver_later
  end

  private

  def user_mailer_class
    return placements_mailer_class if user.service == :placements

    claims_mailer_class
  end

  def placements_mailer_class
    organisation.is_a?(School) ? ::Placements::SchoolUserMailer : ::Placements::ProviderUserMailer
  end

  def claims_mailer_class
    user.is_a?(Claims::ProviderUser) ? Claims::ProviderUserMailer : Claims::UserMailer
  end
end
