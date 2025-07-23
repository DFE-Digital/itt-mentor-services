class Claim::CardComponentPreview < ApplicationComponentPreview
  def default
    claim = FactoryBot.build_stubbed(:claim, :submitted)
    current_user = FactoryBot.build_stubbed(:claims_support_user)

    render Claim::CardComponent.new(claim:, href: "", current_user:)
  end
end
