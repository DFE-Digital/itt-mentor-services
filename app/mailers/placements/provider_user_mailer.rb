class Placements::ProviderUserMailer < Placements::UserMailer
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
    @itt_contact_email = source_organisation.school_contact_email_address
    @placements = source_organisation.placements.where(provider: partner_organisation).decorate.map do |placement|
      { title: placement.title, url: placements_provider_placement_url(partner_organisation, placement) }
    end
    @sign_in_url = sign_in_url
    @service_name = service_name

    notify_email to: user.email, subject: t(".subject")
  end

  def placement_provider_assigned_notification(user, provider, placement)
    @user_name = user.first_name
    @provider_name = provider.name
    @school_name = placement.school.name
    @itt_contact_email = placement.school.school_contact_email_address
    @placement_name = placement.decorate.title
    @placement_url = placements_provider_placement_url(provider, placement)
    @service_name = service_name
    @sign_in_url = sign_in_url

    notify_email to: user.email, subject: t(".subject")
  end

  def placement_provider_removed_notification(user, provider, placement)
    @user_name = user.first_name
    @provider_name = provider.name
    @school_name = placement.school.name
    @itt_contact_email = placement.school.school_contact_email_address
    @placement_name = placement.decorate.title
    @placement_url = placements_provider_placement_url(provider, placement)
    @service_name = service_name
    @sign_in_url = sign_in_url

    notify_email to: user.email, subject: t(".subject")
  end
end
