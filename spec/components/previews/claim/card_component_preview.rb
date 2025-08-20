class Claim::CardComponentPreview < ApplicationComponentPreview
  def default
    claim = FactoryBot.build_stubbed(:claim, :submitted)
    current_user = FactoryBot.build_stubbed(:claims_support_user)

    render Claim::CardComponent.new(claim:, href: "", current_user:)
  end

  def assigned_to_support_user
    current_user = FactoryBot.build_stubbed(:claims_support_user)
    claim = FactoryBot.build_stubbed(:claim, :submitted, support_user: current_user)

    render Claim::CardComponent.new(claim:, href: "", current_user:)
  end

  def clawback_requested
    current_user = FactoryBot.build_stubbed(:claims_support_user)
    support_user = FactoryBot.build_stubbed(:claims_support_user)
    claim = FactoryBot.build_stubbed(
      :claim,
      :submitted,
      status: :clawback_requires_approval,
      support_user: current_user,
      clawback_requested_by: support_user,
    )

    render Claim::CardComponent.new(claim:, href: "", current_user:)
  end

  def clawback_approved
    current_user = FactoryBot.build_stubbed(:claims_support_user)
    support_user = FactoryBot.build_stubbed(:claims_support_user)
    claim = FactoryBot.build_stubbed(
      :claim,
      :submitted,
      status: :clawback_requested,
      support_user: current_user,
      clawback_requested_by: support_user,
      clawback_approved_by: current_user,
    )

    render Claim::CardComponent.new(claim:, href: "", current_user:)
  end
end
