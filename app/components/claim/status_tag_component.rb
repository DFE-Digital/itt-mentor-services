class Claim::StatusTagComponent < ApplicationComponent
  def initialize(claim:, classes: [], html_attributes: {})
    super(classes:, html_attributes:)

    @claim = claim
  end

  def call
    govuk_tag(text: t(".#{claim.status}"), colour:)
  end

  private

  attr_reader :claim

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
      paid: "green",
      payment_information_requested: "light-blue",
      payment_information_sent: "yellow",
      payment_not_approved: "red",
    }.with_indifferent_access
  end
end
