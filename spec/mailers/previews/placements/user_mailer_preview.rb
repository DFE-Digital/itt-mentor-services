class Placements::UserMailerPreview < ActionMailer::Preview
  def user_membership_created_notification
    UserMailer.with(service: :placements).user_membership_created_notification(Placements::User.first, Placements::School.first)
  end

  def user_membership_destroyed_notification
    UserMailer.with(service: :placements).user_membership_destroyed_notification(Placements::User.first, Placements::School.first)
  end
end
