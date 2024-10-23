class Placements::ProviderUserMailer < Placements::ApplicationMailer
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
    @user_name = user.first_name
    @school_name = source_organisation.name
    @provider_name = partner_organisation.name
    @itt_contact_email = source_organisation.school_contact_email_address
    @sign_in_url = sign_in_url
    @service_name = service_name

    notify_email to: user.email, subject: t(".subject")
  end

  def partnership_destroyed_notification(user, source_organisation, partner_organisation)
    @user_name = user.first_name
    @provider_name = partner_organisation.name
    @school_name = source_organisation.name
    placements_school = source_organisation.becomes(Placements::School)
    @itt_contact_email = placements_school.school_contact_email_address
    @placements = placements_school.placements.where(provider: partner_organisation).decorate.map do |placement|
      { title: placement.title, url: placements_provider_placement_url(partner_organisation, placement) }
    end
    @sign_in_url = sign_in_url
    @service_name = service_name

    notify_email to: user.email, subject: t(".subject")
  end

  def placement_provider_assigned_notification(user, provider, placement)
    @user_name = user.first_name
    @provider_name = provider.name
    @school_name = school(placement).name
    @itt_contact_email = school(placement).school_contact_email_address
    @placement_name = placement.decorate.title
    @placement_url = placements_provider_placement_url(provider, placement)
    @service_name = service_name
    @sign_in_url = sign_in_url

    notify_email to: user.email, subject: t(".subject")
  end

  def placement_provider_removed_notification(user, provider, placement)
    notify_email(
      to: user.email,
      subject: t(".subject", school_name: school(placement).name),
      body: t(
        ".body",
        provider_name: provider.name,
        placement_name: placement.decorate.title,
        school_name: school(placement).name,
        school_email: school(placement).school_contact.email_address,
        link: placements_provider_placement_url(provider, placement),
      ),
    )
  end

  private

  def school(placement)
    @school ||= placement.school
  end
end
