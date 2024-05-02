class ApplicationMailer < Mail::Notify::Mailer
  GENERIC_NOTIFY_TEMPLATE = "a2c0c8f0-6d15-47db-b334-5fe198da1740".freeze

  default from: "no-reply@education.gov.uk"

  def notify_email(subject:, **headers)
    headers.merge!(rails_mailer: mailer_name, rails_mail_template: action_name)
    view_mail(GENERIC_NOTIFY_TEMPLATE, subject: environment_prefix + subject, **headers)
  end

  private

  def environment_prefix
    return "" if HostingEnvironment.env.in? %w[production test]

    "[#{HostingEnvironment.env.upcase}] "
  end

  def service_name
    I18n.t("#{params[:service]}.service_name")
  end

  def default_url_options
    { host:, port: ENV["PORT"], protocol: }
  end

  def protocol
    Rails.env.production? ? "https" : "http"
  end

  def host
    case params[:service].to_s
    when "claims"
      ENV["CLAIMS_HOST"]
    when "placements"
      ENV["PLACEMENTS_HOST"]
    end
  end
end
