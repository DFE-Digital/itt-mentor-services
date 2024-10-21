class Placements::SchoolUserMailer < Placements::UserMailer
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
