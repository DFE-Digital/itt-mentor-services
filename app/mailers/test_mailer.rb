class TestMailer < ApplicationMailer
  #TestMailer.dummy_email.deliver_now
  def dummy_email
    @user_name = "Bob"
    mailer_options = { to: "test@example.com", subject: "test" }

    notify_email(mailer_options)
  end
end
