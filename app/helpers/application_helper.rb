module ApplicationHelper
  include Pagy::Frontend

  def current_service
    HostingEnvironment.current_service(request)
  end

  def service_name
    t("#{current_service}.service_name")
  end

  def claims_service?
    current_service == :claims
  end

  def account_navigation_items
    return [] if current_user.blank?

    items = []

    if claims_service?
      items << { text: t("layouts.application.your_account"), href: account_path, current: current_page?(account_path) }

      if current_user.is_a?(Claims::ProviderUser) && current_user.providers.many?
        items << { text: t("layouts.application.change_organisation"), href: claims_providers_path, current: current_page?(claims_providers_path) }
      end
    elsif current_user.support_user?
      items << { text: t("placements.support.header_navigation.organisations"), href: support_organisations_path }
      items << { text: t("placements.support.header_navigation.users"), href: support_support_users_path }
      items << { text: t("placements.support.header_navigation.settings"), href: placements_support_settings_path }
    end

    items << { text: t("layouts.application.sign_out"), href: sign_out_path }
    items
  end

  # The primary navigation shown on the claims-only account page: the same
  # navigation the user sees elsewhere, based on their type and selected
  # organisation. Returns nil when there is no organisation-scoped navigation
  # (e.g. a multi-organisation user who hasn't selected one yet).
  def account_primary_navigation
    if current_user.is_a?(Claims::SupportUser)
      PrimaryNavigationComponent.new(context: :claims_support, current_user:)
    elsif current_user.is_a?(Claims::User) && (school = claims_account_school)
      PrimaryNavigationComponent.new(context: :claims_school, current_user:, organisation: school)
    elsif current_user.is_a?(Claims::ProviderUser) && (provider = claims_account_provider)
      PrimaryNavigationComponent.new(context: :claims_provider, current_user:, organisation: provider)
    end
  end

  # The provider whose navigation should be shown when there's no provider in the
  # URL (the account and change-organisation pages): the user's only provider, or
  # the one they most recently viewed.
  def claims_account_provider
    return unless current_user.is_a?(Claims::ProviderUser)

    remembered_claims_organisation(current_user.providers, :claims_current_provider_id)
  end

  # As claims_account_provider, but for school users on the account page.
  def claims_account_school
    return unless current_user.is_a?(Claims::User)

    remembered_claims_organisation(current_user.schools, :claims_current_school_id)
  end

  def external_link(link)
    return if link.blank?

    unless link.include?("http://") || link.include?("https://")
      link.insert(0, "http://")
    end
    link
  end

  def safe_l(value, **options)
    if value
      l(value, **options)
    else
      "-"
    end
  end

  private

  def remembered_claims_organisation(organisations, session_key)
    return organisations.first if organisations.one?

    organisations.find_by(id: session[session_key])
  end
end
