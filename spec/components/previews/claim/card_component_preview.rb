class Claim::CardComponentPreview < ApplicationComponentPreview
  def default
    claim = FactoryBot.build_stubbed(:claim, :submitted)

    render Claim::CardComponent.new(claim:)
  end
end
