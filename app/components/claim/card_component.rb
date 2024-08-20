class Claim::CardComponent < ApplicationComponent
  attr_reader :claim, :href

  def initialize(claim:, href:, classes: [], html_attributes: {})
    super(classes:, html_attributes:)

    @claim = claim
    @href = href
  end
end
