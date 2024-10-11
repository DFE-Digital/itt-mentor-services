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
    service == :placements ? Placements::UserMailer : Claims::UserMailer
  end
end
