class Claims::ClaimDecorator < Draper::Decorator
  delegate_all

  def support_user_assigned
    if support_user.present?
      support_user.full_name
    else
      I18n.t(".#{translation_path}.support_user.unassigned")
    end
  end

  def provider_responses
    @provider_responses ||= begin
      responses = ""
      mentor_trainings.not_assured.order_by_mentor_full_name.each do |mentor_training|
        responses << "- #{mentor_training.mentor_full_name}: #{mentor_training.reason_not_assured}\n"
      end
      responses
    end
  end

  private

  def translation_path
    "activerecord.attributes.claims/claim"
  end
end
