class Claims::Support::Claim::ResponsesComponent < ApplicationComponent
  attr_reader :claim

  def initialize(claim:, classes: [], html_attributes: {})
    super(classes:, html_attributes:)

    @claim = claim
  end

  def provider_response_exists?
    mentor_trainings.not_assured.pluck(:reason_not_assured).present?
  end

  def provider_response
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

  def school_response_exists?
    rejected_mentor_trainings.pluck(:reason_rejected).present?
  end

  def school_response
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
    @mentor_trainings ||= claim.mentor_trainings.includes(:mentor)
  end

  def not_assured_mentor_trainings
    @not_assured_mentor_trainings ||= mentor_trainings.not_assured
  end

  def rejected_mentor_trainings
    @rejected_mentor_trainings || mentor_trainings.rejected
  end
end
