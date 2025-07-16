class ApplicationMailer < Mail::Notify::Mailer
  GENERIC_NOTIFY_TEMPLATE = "a2c0c8f0-6d15-47db-b334-5fe198da1740".freeze

  default from: "no-reply@education.gov.uk"

  def notify_email(subject:, **headers)
    headers.merge!(rails_mailer: mailer_name, rails_mail_template: action_name)
    view_mail(GENERIC_NOTIFY_TEMPLATE, subject: environment_prefix + subject, **headers)
  end

  private

  def view_mail(_template_id, subject:, to:, **_headers)
    # Compose the email body from the view
    body = render_to_string(template: "#{mailer_name}/#{action_name}")

    NotifyEmailQueue.create!(
      recipient: to,
      subject: subject,
      body: body,
    )

    # Return a dummy Mail::Message object so Rails mailer logic doesn't break
    Mail::Message.new(to: to, subject: subject, body: body)
  end

  def environment_prefix
    return "" if HostingEnvironment.env.in? %w[production test]

    "[#{HostingEnvironment.env.upcase}] "
  end

  def default_url_options
    { host:, port: ENV["PORT"], protocol: }
  end

  def protocol
    Rails.env.production? ? "https" : "http"
  end
end
