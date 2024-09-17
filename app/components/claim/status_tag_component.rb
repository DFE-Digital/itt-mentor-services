class Claim::StatusTagComponent < ApplicationComponent
  attr_reader :claim

  def initialize(claim:, classes: [], html_attributes: {})
    super(classes:, html_attributes:)

    @claim = claim
  end

  def call
    govuk_tag(text: claim.status.humanize, colour:)
  end

  private

  def default_attributes
    super.merge!(class: super.class)
  end

  def colour
    status_colours.fetch(claim.status)
  end

  def status_colours
    {
      internal_draft: "grey",
      draft: "grey",
      submitted: "blue",
      sent_to_esfa: "light-blue",
    }.with_indifferent_access
  end
end
