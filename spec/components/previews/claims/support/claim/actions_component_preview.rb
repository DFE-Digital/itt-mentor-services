class Claims::Support::Claim::ActionsComponentPreview < ApplicationComponentPreview
  def default
    claim = FactoryBot.build(:claim, :submitted, school:)
    render Claims::Support::Claim::ActionsComponent.new(claim:)
  end

  def with_payment_information_requested_claim
    claim = FactoryBot.build(:claim, :payment_information_requested, school:)
    render Claims::Support::Claim::ActionsComponent.new(claim:)
  end

  def with_payment_information_sent_claim
    claim = FactoryBot.build(:claim, :payment_information_sent, school:)
    render Claims::Support::Claim::ActionsComponent.new(claim:)
  end

  def with_sampling_in_progress_claim
    claim = FactoryBot.build(:claim, :sampling_in_progress, school:)
    render Claims::Support::Claim::ActionsComponent.new(claim:)
  end

  def with_sampling_provider_not_approved_claim
    claim = FactoryBot.build(:claim, :sampling_provider_not_approved, school:)
    render Claims::Support::Claim::ActionsComponent.new(claim:)
  end

  def with_sampling_not_approved_claim
    claim = FactoryBot.build(:claim, :sampling_not_approved, school:)
    render Claims::Support::Claim::ActionsComponent.new(claim:)
  end
end
