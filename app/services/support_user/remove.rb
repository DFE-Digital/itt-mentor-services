class SupportUser::Remove < ApplicationService
  attr_reader :support_user

  def initialize(support_user:)
    @support_user = support_user
  end

  def call
    return if support_user.discarded?

    # Support users are soft deleted
    support_user.discard!
    send_email_notification
    true
  end

  private

  def send_email_notification
    support_user_mailer_class(support_user.service).support_user_removal_notification(support_user).deliver_later
  end

  def support_user_mailer_class(service)
    service == :placements ? Placements::SupportUserMailer : Claims::SupportUserMailer
  end
end
