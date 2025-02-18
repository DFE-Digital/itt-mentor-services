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
    FactoryBot.build_stubbed(:placements_user)
  end

  def school
    FactoryBot.build_stubbed(:placements_school)
  end

  def provider
    PreviewProvider.new
  end

  def provider_email_address
    FactoryBot.build_stubbed(:provider_email_address, primary: true)
  end

  class PreviewProvider < Provider
    def name
      "Test Provider"
    end

    def primary_email_address
      "test@example.com"
    end
  end
end
