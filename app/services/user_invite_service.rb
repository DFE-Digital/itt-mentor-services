class UserInviteService
  include ServicePattern

  def initialize(user, school, sign_in_url)
    @user = user
    @school = school
    @sign_in_url = sign_in_url
  end

  attr_reader :user, :school, :sign_in_url

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
      attach_to_school
    end
  end

  def attach_to_school
    Membership.create!(user_id: user.id, organisation_type: "School", organisation_id: school.id)
  end

  def send_email
    NotifyMailer.send_school_invite_email(user, school, sign_in_url).deliver_later
  end
end
