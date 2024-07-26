class Placements::UserMailerPreview < ActionMailer::Preview
  def user_membership_created_notification
    UserMailer.with(service: :placements).user_membership_created_notification(Placements::User.first, Placements::School.first)
  end

  def user_membership_destroyed_notification
    UserMailer.with(service: :placements).user_membership_destroyed_notification(Placements::User.first, Placements::School.first)
  end

  def partnership_created_notification
    UserMailer.with(service: :placements).partnership_created_notification(Placements::User.first, Placements::School.first, Placements::Provider.first)
  end

  def partnership_destroyed_notification
    UserMailer.with(service: :placements).partnership_destroyed_notification(Placements::User.first, Placements::School.first, Placements::Provider.first)
  end

  def placement_provider_assigned_notification
    UserMailer.with(service: :placements).placement_provider_assigned_notification(Placements::User.first, Placements::Provider.first, Placement.first)
  end

  def placement_provider_removed_notification
    UserMailer.with(service: :placements).placement_provider_removed_notification(Placements::User.first, Placements::Provider.first, Placement.first)
  end
end
