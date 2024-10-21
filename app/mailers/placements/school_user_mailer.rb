class Placements::SchoolUserMailer < Placements::ApplicationMailer
  def user_membership_created_notification(user, organisation)
    notify_email to: user.email,
                 subject: t(".subject", service_name:),
                 body: t(
                   ".body",
                   user_name: user.first_name,
                   organisation_name: organisation.name,
                   service_name:,
                   heading: t(".heading"),
                   support_email:,
                   sign_in_url:,
                 )
  end

  def user_membership_destroyed_notification(user, organisation)
    notify_email to: user.email,
                 subject: t(".subject", service_name:),
                 body: t(
                   ".body",
                   user_name: user.first_name,
                   organisation_name: organisation.name,
                   service_name:,
                   support_email:,
                 )
  end

  def partnership_created_notification(user, source_organisation, partner_organisation)
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
