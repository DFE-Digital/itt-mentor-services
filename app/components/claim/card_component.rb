class Claim::CardComponent < ApplicationComponent
  def initialize(claim:, href:, current_user:, classes: [], html_attributes: {})
    super(classes:, html_attributes:)

    @claim = claim.decorate
    @href = href
    @current_user = current_user
  end

  private

  attr_reader :claim, :href, :current_user
end
