class ApplicationMailer < Mail::Notify::Mailer
  GENERIC_NOTIFY_TEMPLATE = "4181b9bb-b326-488d-9ff6-b7ea15158880".freeze

  def notify_email(headers)
    headers.merge!(rails_mailer: mailer_name, rails_mail_template: action_name)
    view_mail(GENERIC_NOTIFY_TEMPLATE, headers)
  end
end
