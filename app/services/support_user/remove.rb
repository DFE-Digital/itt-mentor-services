class SupportUser::Remove
  include ServicePattern

  attr_reader :support_user

  def initialize(support_user:)
    @support_user = support_user
  end

  def call
    # Support users are soft deleted
    if support_user.discard
      send_email_notification

      true
    else
      false
    end
  end

  private

  def send_email_notification
    SupportUserMailer.with(service: support_user.service).support_user_removal_notification(support_user).deliver_later
  end
end
