class Claims::Support::Claim::ActionsComponentPreview < ApplicationComponentPreview
  def default
    claim = FactoryBot.build_stubbed(:claim, :payment_information_requested)
    render Claims::Support::Claim::ActionsComponent.new(claim:)
  end

  def with_payment_information_requested_claim
    claim = FactoryBot.build_stubbed(:claim, :payment_information_requested)
    render Claims::Support::Claim::ActionsComponent.new(claim:)
  end

  def with_payment_information_sent_claim
    claim = FactoryBot.build_stubbed(:claim, :payment_information_sent)
    render Claims::Support::Claim::ActionsComponent.new(claim:)
  end

  def with_sampling_in_progress_claim
    claim = FactoryBot.build_stubbed(:claim, :sampling_in_progress)
    render Claims::Support::Claim::ActionsComponent.new(claim:)
  end

  def with_sampling_provider_not_approved_claim
    claim = FactoryBot.build_stubbed(:claim, :sampling_provider_not_approved)
    render Claims::Support::Claim::ActionsComponent.new(claim:)
  end

  def with_sampling_not_approved_claim
    claim = FactoryBot.build_stubbed(:claim, :sampling_not_approved)
    render Claims::Support::Claim::ActionsComponent.new(claim:)
  end
end
