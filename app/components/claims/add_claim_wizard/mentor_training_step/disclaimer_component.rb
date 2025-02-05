class Claims::AddClaimWizard::MentorTrainingStep::DisclaimerComponent < ApplicationComponent
  attr_reader :mentor_training_step

  delegate :training_allowance, to: :mentor_training_step

  def initialize(mentor_training_step:, classes: [], html_attributes: {})
    super(classes:, html_attributes:)

    @mentor_training_step = mentor_training_step
  end

  def call
    govuk_inset_text do
      tag.p(sanitize(t(".disclaimer", mentor_name:, provider_name:, count: training_allowance.remaining_hours))) +
        tag.p(sanitize(t(".disclaimer_contact", support_link:)))
    end
  end

  def render?
    training_allowance.remaining_hours < training_allowance.total_hours
  end

  private

  def mentor_name
    mentor_training_step.mentor_full_name
  end

  def provider_name
    mentor_training_step.provider_name
  end

  def support_link
    govuk_mail_to t("claims.support_email")
  end
end
