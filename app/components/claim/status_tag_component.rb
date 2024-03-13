class Claim::StatusTagComponent < ApplicationComponent
  attr_reader :claim

  def initialize(claim:, classes: [], html_attributes: {})
    super(classes:, html_attributes:)

    @claim = claim
  end

  def call
    content_tag(:p, claim.status.humanize, class: "govuk-tag #{css_class}")
  end

  private

  def css_class
    style_status_classes.fetch(claim.status)
  end

  def style_status_classes
    {
      draft: "govuk-tag--grey",
      submitted: "govuk-tag--blue",
    }.with_indifferent_access
  end
end
