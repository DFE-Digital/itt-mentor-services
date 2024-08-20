class ApplicationMailer < Mail::Notify::Mailer
  GENERIC_NOTIFY_TEMPLATE = "a2c0c8f0-6d15-47db-b334-5fe198da1740".freeze

  default from: "no-reply@education.gov.uk"

  def notify_email(subject:, **headers)
    headers.merge!(
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      subject: environment_prefix + subject,
    )

    view_mail(GENERIC_NOTIFY_TEMPLATE, **headers)
  end

  private

  def environment_prefix
    return "" if HostingEnvironment.env.in? %w[production test]

    "[#{HostingEnvironment.env.upcase}] "
  end

  def service
    params[:service]
  end

  def service_name
    I18n.t("#{service}.service_name")
  end

  def support_email
    I18n.t("#{service}.support_email")
  end

  def default_url_options
    { host:, port: ENV["PORT"], protocol: }
  end

  def protocol
    Rails.env.production? ? "https" : "http"
  end

  def host
    case service.to_s
    when "claims"
      ENV["CLAIMS_HOST"]
    when "placements"
      ENV["PLACEMENTS_HOST"]
    end
  end
end
