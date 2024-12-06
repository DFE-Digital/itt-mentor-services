class Claim::CardComponent < ApplicationComponent
  def initialize(claim:, href:, classes: [], html_attributes: {})
    super(classes:, html_attributes:)

    @claim = claim
    @href = href
  end

  private

  attr_reader :claim, :href
end
