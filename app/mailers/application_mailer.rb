class ApplicationMailer < Mail::Notify::Mailer
  GENERIC_NOTIFY_TEMPLATE = "a2c0c8f0-6d15-47db-b334-5fe198da1740".freeze

  def notify_email(headers)
    headers.merge!(rails_mailer: mailer_name, rails_mail_template: action_name)
    view_mail(GENERIC_NOTIFY_TEMPLATE, headers)
  end
end
