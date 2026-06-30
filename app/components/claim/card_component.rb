class Claim::CardComponent < ApplicationComponent
  def initialize(claim:, href:, current_user:, status_text: nil, show_provider: true, classes: [], html_attributes: {})
    super(classes:, html_attributes:)

    @claim = claim.decorate
    @href = href
    @current_user = current_user
    @status_text = status_text
    @show_provider = show_provider
  end

  private

  attr_reader :claim, :href, :current_user, :status_text, :show_provider
end
