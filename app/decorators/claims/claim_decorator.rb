class Claims::ClaimDecorator < Draper::Decorator
  delegate_all

  def support_user_assigned
    if support_user.present?
      support_user.full_name
    else
      I18n.t(".#{translation_path}.support_user.unassigned")
    end
  end

  private

  def translation_path
    "activerecord.attributes.claims/claim"
  end
end
