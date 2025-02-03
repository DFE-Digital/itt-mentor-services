class Claims::Claim::MentorsForm::DisclaimerComponent < ApplicationComponent
  attr_reader :mentors_form

  def initialize(mentors_form:, classes: [], html_attributes: {})
    super(classes:, html_attributes:)

    @mentors_form = mentors_form
  end

  def call
    govuk_details summary_text: t(".mentor_not_listed") do
      tag.p(sanitize(t(".disclaimer", provider_name:))) +
        tag.p(sanitize(t(".disclaimer_contact", email_link:)))
    end
  end

  def render?
    !mentors_form.all_school_mentors_visible?
  end

  private

  def provider_name
    mentors_form.claim.provider_name
  end

  def email_link
    govuk_mail_to t("claims.support_email")
  end
end
