class Placements::UserMailer < Placements::ApplicationMailer
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
    if partner_organisation.is_a?(Provider)
      partner_class = "provider"
      link = placements_provider_partner_schools_url(partner_organisation)
    elsif partner_organisation.is_a?(School)
      partner_class = "school"
      link = placements_school_partner_providers_url(partner_organisation)
    else
      raise InvalidOrganisationError, "#partner_organisation must be either a Provider or School"
    end

    notify_email(
      to: user.email,
      subject: t(".subject.#{partner_class}", organisation: partner_organisation.name),
      body: t(
        ".body.#{partner_class}",
        user_name: user.full_name,
        source_organisation: source_organisation.name,
        partner_organisation: partner_organisation.name,
        link:,
      ),
    )
  end

  def partnership_destroyed_notification(user, source_organisation, partner_organisation)
    if partner_organisation.is_a?(Provider)
      partner_class = "provider"
      link = placements_provider_partner_schools_url(partner_organisation)
    elsif partner_organisation.is_a?(School)
      partner_class = "school"
      link = placements_school_partner_providers_url(partner_organisation)
    else
      raise InvalidOrganisationError, "#partner_organisation must be either a Provider or School"
    end

    notify_email(
      to: user.email,
      subject: t(".subject.#{partner_class}", organisation: partner_organisation.name),
      body: t(
        ".body.#{partner_class}",
        user_name: user.full_name,
        source_organisation: source_organisation.name,
        partner_organisation: partner_organisation.name,
        link:,
      ),
    )
  end

  def placement_provider_assigned_notification(user, provider, placement)
    placement_link = placements_provider_placement_url(provider, placement)
    school = placement.school

    notify_email(
      to: user.email,
      subject: t(".subject", school_name: school.name),
      body: t(
        ".body",
        provider_name: provider.name,
        placement_name: placement.decorate.title,
        school_name: school.name,
        school_email: school.school_contact.email_address,
        link: placement_link,
      ),
    )
  end

  def placement_provider_removed_notification(user, provider, placement)
    placement_link = placements_provider_placement_url(provider, placement)
    school = placement.school

    notify_email(
      to: user.email,
      subject: t(".subject", school_name: school.name),
      body: t(
        ".body",
        provider_name: provider.name,
        placement_name: placement.decorate.title,
        school_name: school.name,
        school_email: school.school_contact.email_address,
        link: placement_link,
      ),
    )
  end
end

class InvalidOrganisationError < StandardError; end
