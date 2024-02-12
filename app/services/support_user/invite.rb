class SupportUser::Invite
  include ServicePattern

  attr_reader :support_user

  def initialize(support_user:)
    @support_user = support_user
  end

  def call
    SupportUserMailer.with(service: support_user.service).support_user_invitation(support_user).deliver_later
  end
end
