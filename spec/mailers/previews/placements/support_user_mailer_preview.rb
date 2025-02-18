class Placements::SupportUserMailerPreview < ActionMailer::Preview
  def support_user_invitation
    Placements::SupportUserMailer.support_user_invitation(support_user)
  end

  def support_user_removal_notification
    Placements::SupportUserMailer.support_user_removal_notification(support_user)
  end

  private

  def support_user
    FactoryBot.build_stubbed(:placements_support_user)
  end
end
