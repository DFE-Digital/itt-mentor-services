class Placements::ProviderUserMailerPreview < ActionMailer::Preview
  def user_membership_created_notification
    Placements::ProviderUserMailer.user_membership_created_notification(Placements::User.first, Placements::School.first)
  end

  def user_membership_destroyed_notification
    Placements::ProviderUserMailer.user_membership_destroyed_notification(Placements::User.first, Placements::School.first)
  end

  def partnership_created_notification
    Placements::ProviderUserMailer.partnership_created_notification(Placements::User.first, Placements::School.first, Placements::Provider.first)
  end

  def partnership_destroyed_notification
    Placements::ProviderUserMailer.partnership_destroyed_notification(Placements::User.first, Placements::School.first, Placements::Provider.first)
  end

  def placement_provider_assigned_notification
    Placements::ProviderUserMailer.placement_provider_assigned_notification(Placements::User.first, Placements::Provider.first, Placement.first)
  end

  def placement_provider_removed_notification
    Placements::ProviderUserMailer.placement_provider_removed_notification(Placements::User.first, Placements::Provider.first, Placement.first)
  end
end
