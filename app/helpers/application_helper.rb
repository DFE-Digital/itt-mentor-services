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
end
