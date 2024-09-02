class User::Invite < ApplicationService
  def initialize(user:, organisation:)
    @user = user
    @organisation = organisation
  end

  attr_reader :user, :organisation, :service

  def call
    UserMailer.with(service: user.service).user_membership_created_notification(user, organisation).deliver_later
  end
end
