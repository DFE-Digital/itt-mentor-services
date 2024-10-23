class Placements::SchoolUserMailerPreview < ActionMailer::Preview
  def user_membership_created_notification
    Placements::SchoolUserMailer.user_membership_created_notification(Placements::User.first, Placements::School.first)
  end

  def user_membership_destroyed_notification
    Placements::SchoolUserMailer.user_membership_destroyed_notification(Placements::User.first, Placements::School.first)
  end

  def partnership_created_notification
    Placements::SchoolUserMailer.partnership_created_notification(Placements::User.first, Placements::Provider.first, Placements::School.first)
  end

  def partnership_destroyed_notification
    Placements::SchoolUserMailer.partnership_destroyed_notification(Placements::User.first, Placements::Provider.first, Placements::School.first)
  end
end
