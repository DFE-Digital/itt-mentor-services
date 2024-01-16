class UserInviteService
  include ServicePattern

  def initialize(user, organisation, sign_in_url)
    @user = user
    @organisation = organisation
    @sign_in_url = sign_in_url
  end

  attr_reader :user, :organisation, :sign_in_url

  def call
    if save_user
      send_email
      true
    else
      false
    end
  end

  private

  def save_user
    ActiveRecord::Base.transaction do
      user.save!
      attach_to_organisation
    end
  end

  def attach_to_organisation
    Membership.create!(user_id: user.id, organisation:)
  end

  def send_email
    NotifyMailer.send_organisation_invite_email(user, organisation, sign_in_url).deliver_later
  end
end
