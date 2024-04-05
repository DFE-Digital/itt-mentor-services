class Claim::CardComponentPreview < ApplicationComponentPreview
  def default
    render Claim::CardComponent.new(claim:)
  end

  private

  def claim
    Claims::Claim.submitted.first
  end
end
