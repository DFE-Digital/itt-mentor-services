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
      draft: "grey",
      submitted: "blue",
      payment_in_progress: "turquoise",
      payment_information_requested: "light-blue",
      payment_information_sent: "yellow",
      paid: "green",
      payment_not_approved: "red",
      sampling_in_progress: "purple",
      sampling_provider_not_approved: "pink",
      sampling_not_approved: "pink",
      clawback_requested: "orange",
      clawback_in_progress: "orange",
      clawback_complete: "red",
    }.with_indifferent_access
  end
end
