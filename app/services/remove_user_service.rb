class RemoveUserService
  include ServicePattern

  def initialize(user, organisation)
    @user = user
    @organisation = organisation
  end

  attr_reader :user, :organisation

  def call
    membership = user.user_memberships.find_by(organisation:)
    ActiveRecord::Base.transaction do
      membership.destroy!
      UserMailer.removal_email(user, organisation).deliver_later
    end
    true
  end
end
