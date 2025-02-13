class Claims::Support::Claim::ResponsesComponent < ApplicationComponent
  attr_reader :claim

  def initialize(claim:, classes: [], html_attributes: {})
    super(classes:, html_attributes:)

    @claim = claim
  end

  def provider_response
    not_assured_mentor_trainings = mentor_trainings.not_assured
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

  def school_response
    rejected_mentor_trainings = mentor_trainings.rejected
    return "" if rejected_mentor_trainings.blank?

    content_tag(:ul, class: "govuk-list") do
      rejected_mentor_trainings.order_by_mentor_full_name.each do |mentor_training|
        concat(
          content_tag(
            :li,
            "#{mentor_training.mentor_full_name}: #{mentor_training.reason_rejected}",
          ),
        )
      end
    end
  end

  private

  def mentor_trainings
    @mentor_trainings ||= claim.mentor_trainings
  end
end
