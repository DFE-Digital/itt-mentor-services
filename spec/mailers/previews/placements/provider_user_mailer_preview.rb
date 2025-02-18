class Placements::ProviderUserMailerPreview < ActionMailer::Preview
  def user_membership_created_notification
    Placements::ProviderUserMailer.user_membership_created_notification(user, school)
  end

  def user_membership_destroyed_notification
    Placements::ProviderUserMailer.user_membership_destroyed_notification(user, school)
  end

  def partnership_created_notification
    Placements::ProviderUserMailer.partnership_created_notification(user, school, provider)
  end

  def partnership_destroyed_notification
    Placements::ProviderUserMailer.partnership_destroyed_notification(user, school, provider)
  end

  def placement_provider_assigned_notification
    Placements::ProviderUserMailer.placement_provider_assigned_notification(user, provider, placement)
  end

  def placement_provider_removed_notification
    Placements::ProviderUserMailer.placement_provider_removed_notification(user, provider, placement)
  end

  private

  def user
    FactoryBot.build_stubbed(:placements_user)
  end

  def school
    FactoryBot.build_stubbed(:placements_school)
  end

  def provider
    FactoryBot.build_stubbed(:placements_provider)
  end

  def placement
    FactoryBot.build_stubbed(:placement, school:, provider:)
  end
end
