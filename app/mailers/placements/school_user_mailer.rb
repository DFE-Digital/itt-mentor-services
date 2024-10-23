class Placements::SchoolUserMailer < Placements::UserMailer
  def user_membership_destroyed_notification(user, organisation)
    @itt_contact_email = organisation.school_contact_email_address

    super
  end

  def partnership_created_notification(user, source_organisation, partner_organisation)
    @user_name = user.first_name
    @school_name = partner_organisation.name
    @provider_name = source_organisation.name
    @provider_email_address = source_organisation.email_address
    @sign_in_url = sign_in_url
    @service_name = service_name

    notify_email to: user.email, subject: t(".subject")
  end

  def partnership_destroyed_notification(user, source_organisation, partner_organisation)
    @user_name = user.first_name
    @school_name = partner_organisation.name
    @provider_name = source_organisation.name
    @provider_email_address = source_organisation.email_address
    placements_school = partner_organisation.becomes(Placements::School)
    @placements = placements_school.placements.where(provider: source_organisation).decorate.map do |placement|
      { title: placement.title, url: placements_provider_placement_url(source_organisation, placement) }
    end
    @sign_in_url = sign_in_url
    @service_name = service_name

    notify_email to: user.email, subject: t(".subject")
  end
end
