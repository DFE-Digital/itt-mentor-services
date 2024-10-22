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
    notify_email(
      to: user.email,
      subject: t(".subject", organisation: partner_organisation.name),
      body: t(
        ".body",
        user_name: user.full_name,
        source_organisation: source_organisation.name,
        partner_organisation: partner_organisation.name,
        link: placements_school_partner_providers_url(partner_organisation),
      ),
    )
  end

end
