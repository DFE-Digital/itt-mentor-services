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

  def placement_information_added_notification_green_path
    Placements::SchoolUserMailer.placement_information_added_notification(
      user,
      school_with_appetite("actively_looking"),
      [placement],
      academic_year,
    )
  end

  def placement_information_added_notification_amber_path
    Placements::SchoolUserMailer.placement_information_added_notification(
      user,
      school_with_appetite("interested"),
      [placement],
      academic_year,
    )
  end

  def partnership_destroyed_notification
    Placements::SchoolUserMailer.partnership_destroyed_notification(user, provider, school)
  end

  def placement_provider_removed_notification
    Placements::SchoolUserMailer.placement_provider_removed_notification(user, school, provider, placement)
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

  def school_with_appetite(appetite)
    school = Placements::School.new(
      id: stubbed_id,
      name: "Test School",
    )

    hosting_interest = hosting_interest(appetite)

    school.define_singleton_method(:current_hosting_interest) do |*_args|
      hosting_interest
    end

    school.define_singleton_method(:school_contact_email_address) do |*_args|
      "test@sample.com"
    end

    school
  end

  def hosting_interest(appetite)
    Placements::HostingInterest.new(
      id: stubbed_id,
      academic_year:,
      appetite:,
    )
  end

  def school
    Placements::School.new(id: stubbed_id, name: "Test School")
  end

  def provider
    PreviewProvider.new(id: stubbed_id, name: "Test Provider")
  end

  def placement
    Placement.new(id: stubbed_id, school:, provider:, subject:)
  end

  def subject
    Subject.new(id: stubbed_id, name: "English")
  end

  def academic_year
    Placements::AcademicYear.current.next
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
