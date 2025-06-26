class Placements::SchoolUserMailer < Placements::UserMailer
  def user_membership_created_notification(user, organisation)
    @campaign_type = "school"

    super
  end

  def user_membership_destroyed_notification(user, organisation)
    @itt_contact_email = organisation.school_contact_email_address

    super
  end

  def placement_information_added_notification(user, organisation, placements, academic_year)
    @user_name = user.first_name
    @placements = placements.map do |placement|
      { title: placement.decorate.title, url: placements_school_placement_url(organisation, placement, utm_source: "email", utm_medium: "notification", utm_campaign: "school") }
    end
    @contact_email = organisation.school_contact_email_address
    @service_name = service_name
    @hosting_interest = organisation.current_hosting_interest(academic_year:)
    @sign_in_url = sign_in_url(utm_source: "email", utm_medium: "notification", utm_campaign: "school")

    notify_email to: user.email, subject: t(".subject")
  end

  def partnership_created_notification(user, source_organisation, partner_organisation)
    @user_name = user.first_name
    @school_name = partner_organisation.name
    @provider_name = source_organisation.name
    @provider_email_address = source_organisation.primary_email_address
    @sign_in_url = sign_in_url(utm_source: "email", utm_medium: "notification", utm_campaign: "school")
    @service_name = service_name

    notify_email to: user.email, subject: t(".subject")
  end

  def partnership_destroyed_notification(user, source_organisation, partner_organisation)
    @user_name = user.first_name
    @school_name = partner_organisation.name
    @provider_name = source_organisation.name
    @provider_email_address = source_organisation.primary_email_address
    placements_school = partner_organisation.becomes(Placements::School)
    @placements = placements_school.placements.where(provider: source_organisation).decorate.map do |placement|
      { title: placement.title, url: placements_school_placement_url(placements_school, placement, utm_source: "email", utm_medium: "notification", utm_campaign: "school") }
    end
    @sign_in_url = sign_in_url(utm_source: "email", utm_medium: "notification", utm_campaign: "school")
    @service_name = service_name

    notify_email to: user.email, subject: t(".subject")
  end

  def placement_provider_removed_notification(user, school, provider, placement)
    @user_name = user.first_name
    @school_name = school.name

    @provider_email_address = provider.primary_email_address
    @provider_name = provider.name
    @placement_name = placement.decorate.title
    @placement_url = placements_school_placement_url(school, placement, utm_source: "email", utm_medium: "notification", utm_campaign: "school")
    @service_name = service_name
    @sign_in_url = sign_in_url(utm_source: "email", utm_medium: "notification", utm_campaign: "school")

    notify_email to: user.email, subject: t(".subject")
  end
end
