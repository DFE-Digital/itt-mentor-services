class Claim::ProviderStatusTagComponent < ApplicationComponent
  attr_reader :claim

  STATUS_TEXT_OVERRIDES = {
    sampling_provider_not_approved: "Amended",
    paid: "Approved",
  }.freeze

  def initialize(claim:, classes: [], html_attributes: {})
    super(classes:, html_attributes:)

    @claim = claim
  end

  def call
    govuk_tag(text: status_text, colour:)
  end

  private

  def default_attributes
    super.merge!(class: super.class)
  end

  def status_text
    STATUS_TEXT_OVERRIDES.fetch(claim.status.to_sym) do
      Claims::Claim.human_attribute_name("status.#{claim.status}")
    end
  end

  def colour
    status_colours.fetch(claim.status)
  end

  def status_colours
    {
      sampling_in_progress: "yellow",
      sampling_provider_not_approved: "turquoise",
      paid: "blue",
    }.with_indifferent_access
  end
end
