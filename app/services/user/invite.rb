class User::Invite < ApplicationService
  def initialize(user:, organisation:)
    @user = user
    @organisation = organisation
  end

  attr_reader :user, :organisation, :service

  def call
    user_mailer_class(user.service).user_membership_created_notification(user, organisation).deliver_later
  end

  private

  def user_mailer_class(service)
    service == :placements ? placements_mailer_class : Claims::UserMailer
  end

  def placements_mailer_class
    organisation.is_a?(School) ? ::Placements::SchoolUserMailer : ::Placements::ProviderUserMailer
  end
end
