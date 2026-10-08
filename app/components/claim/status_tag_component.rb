class Claim::StatusTagComponent < ApplicationComponent
  attr_reader :claim

  def initialize(claim:, classes: [], html_attributes: {})
    super(classes:, html_attributes:)

    @claim = claim
  end

  def call
    status_tag = govuk_tag(text: Claims::Claim.human_attribute_name("status.#{claim.status}"), colour:)
    return status_tag unless claim.amendment_deadline_passed?

    safe_join([status_tag, govuk_tag(text: t(".past_deadline"), colour: "red")], " ")
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
      submitted: "teal",
      payment_in_progress: "yellow",
      payment_information_requested: "teal",
      payment_information_sent: "yellow",
      paid: "blue",
      payment_not_approved: "orange",
      sampling_in_progress: "yellow",
      sampling_provider_not_approved: "teal",
      sampling_not_approved: "teal",
      clawback_requested: "teal",
      clawback_in_progress: "yellow",
      clawback_complete: "blue",
      invalid_provider: "red",
      clawback_requires_approval: "orange",
      clawback_rejected: "red",
    }.with_indifferent_access
  end
end
