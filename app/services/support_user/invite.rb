class SupportUser::Invite < ApplicationService
  attr_reader :support_user

  def initialize(support_user:)
    @support_user = support_user
  end

  def call
    support_user_mailer_class(support_user.service).support_user_invitation(support_user).deliver_later
  end

  private

  def support_user_mailer_class(service)
    service == :placements ? Placements::SupportUserMailer : Claims::SupportUserMailer
  end
end
