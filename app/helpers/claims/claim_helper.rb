module Claims::ClaimHelper
  def claim_statuses_for_selection
    Claims::Claim.statuses.values.reject { |status|
      Claims::Claim::DRAFT_STATUSES.map(&:to_s).include?(status)
    }.sort
  end

  def claim_provider_response(claim)
    not_assured_mentor_trainings = claim.mentor_trainings.not_assured
    return "" if not_assured_mentor_trainings.blank?

    content_tag(:ul, class: "govuk-list") do
      not_assured_mentor_trainings.order_by_mentor_full_name.each do |mentor_training|
        concat(
          content_tag(
            :li,
            "#{mentor_training.mentor_full_name}: #{mentor_training.reason_not_assured}",
          ),
        )
      end
    end
  end
end
