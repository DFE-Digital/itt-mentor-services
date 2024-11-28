class Claims::AddClaimWizard::MentorStep::DisclaimerComponent < ApplicationComponent
  attr_reader :mentor_step

  def initialize(mentor_step:, classes: [], html_attributes: {})
    super(classes:, html_attributes:)

    @mentor_step = mentor_step
  end

  def call
    govuk_details summary_text: t(".mentor_not_listed") do
      tag.p(sanitize(t(".disclaimer", provider_name:))) +
        tag.p(sanitize(t(".disclaimer_contact", email_link:)))
    end
  end

  def render?
    !mentor_step.all_school_mentors_visible?
  end

  private

  def provider_name
    mentor_step.claim.provider_name
  end

  def email_link
    govuk_mail_to t("claims.support_email")
  end
end
