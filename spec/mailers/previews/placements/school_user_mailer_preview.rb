class Placements::SchoolUserMailerPreview < ActionMailer::Preview
  def user_membership_created_notification
    Placements::SchoolUserMailer.user_membership_created_notification(user, school)
  end

  def user_membership_destroyed_notification
    Placements::SchoolUserMailer.user_membership_destroyed_notification(user, school)
  end

  def partnership_created_notification
    Placements::SchoolUserMailer.partnership_created_notification(user, provider, school)
  end

  def partnership_destroyed_notification
    Placements::SchoolUserMailer.partnership_destroyed_notification(user, provider, school)
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
    Placements::School.new(id: stubbed_id, name: "Test School")
  end

  def provider
    PreviewProvider.new(id: stubbed_id, name: "Test Provider")
  end

  def stubbed_id
    SecureRandom.uuid
  end

  class PreviewProvider < Placements::Provider
    def primary_email_address
      "test@example.com"
    end
  end
end
