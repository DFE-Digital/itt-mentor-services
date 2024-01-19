class SupportUser::Invite
  include ServicePattern

  attr_reader :support_user

  def initialize(support_user:)
    @support_user = support_user
  end

  def call
    if support_user.save
      send_email_notification

      true
    else
      false
    end
  end

  private

  def send_email_notification
    SupportUserMailer.with(service: support_user.service).support_user_invitation(support_user).deliver_later
  end
end
