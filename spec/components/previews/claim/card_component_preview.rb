class Claim::CardComponentPreview < ApplicationComponentPreview
  def default
    claim = FactoryBot.build(:claim, :submitted, id: SecureRandom.uuid)

    render Claim::CardComponent.new(claim:)
  end
end
