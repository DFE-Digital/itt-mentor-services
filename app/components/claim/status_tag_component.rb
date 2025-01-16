class Claim::StatusTagComponent < ApplicationComponent
  attr_reader :claim

  def initialize(claim:, classes: [], html_attributes: {})
    super(classes:, html_attributes:)

    @claim = claim
  end

  def call
    govuk_tag(text: Claims::Claim.human_attribute_name("status.#{claim.status}"), colour:)
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
      draft: "yellow",
      submitted: "turquoise",
      payment_in_progress: "yellow",
      payment_information_requested: "turquoise",
      payment_information_sent: "yellow",
      paid: "blue",
      payment_not_approved: "orange",
      sampling_in_progress: "yellow",
      sampling_provider_not_approved: "turquoise",
      sampling_not_approved: "turquoise",
      clawback_requested: "turquoise",
      clawback_in_progress: "yellow",
      clawback_complete: "blue",
    }.with_indifferent_access
  end
end
