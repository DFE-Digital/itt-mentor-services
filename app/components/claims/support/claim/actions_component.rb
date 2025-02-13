class Claims::Support::Claim::ActionsComponent < ApplicationComponent
  attr_reader :claim

  def initialize(claim:, classes: [], html_attributes: {})
    super(classes:, html_attributes:)

    @claim = claim
  end

  def render?
    %w[
      payment_information_requested
      payment_information_sent
      sampling_in_progress
      sampling_provider_not_approved
      sampling_not_approved
    ].include?(claim.status)
  end
end
