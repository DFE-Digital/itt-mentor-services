class Claim::StatusTagComponent < ApplicationComponent
  attr_reader :claim

  def initialize(claim:, classes: [], html_attributes: {})
    super(classes:, html_attributes:)

    @claim = claim
  end

  def call
    css_class = claim.draft ? "govuk-tag--grey" : "govuk-tag--blue"
    text = claim.draft ? t(".draft") : t(".submitted")

    content_tag(:p, text, class: "govuk-tag #{css_class}")
  end
end
