module ApplicationHelper
  include Pagy::Frontend

  def current_service
    HostingEnvironment.current_service(request)
  end

  def service_name
    t("#{current_service}.service_name")
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
      l(value, **options) if value
    else
      "-"
    end
  end
end
