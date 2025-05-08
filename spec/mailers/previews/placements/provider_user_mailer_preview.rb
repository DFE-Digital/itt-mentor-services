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
    Placements::User.new(
      id: stubbed_id,
      first_name: "Joe",
      last_name: "Bloggs",
      email: "joe_bloggs@example.com",
    )
  end

  def school
    Placements::School.new(id: stubbed_id, name: "Test School", school_contact:)
  end

  def school_contact
    Placements::SchoolContact.new(
      id: stubbed_id,
      first_name: "Joe",
      last_name: "Bloggs",
      email_address: "joe_bloggs@example.com",
    )
  end

  def provider
    Placements::Provider.new(id: stubbed_id, name: "Test Provider")
  end

  def placement
    Placement.new(id: stubbed_id, school:, provider:, subject:)
  end

  def subject
    Subject.new(id: stubbed_id, name: "English")
  end

  def stubbed_id
    SecureRandom.uuid
  end
end
