class Claims::Support::Claim::ResponsesComponentPreview < ApplicationComponentPreview
  # payment_information_requested payment_information_sent
  def default
    claim = FactoryBot.build_stubbed(:claim, :payment_information_requested, unpaid_reason: Faker::Lorem.paragraph)
    render Claims::Support::Claim::ResponsesComponent.new(claim:)
  end

  def with_payment_information_requested_claim
    claim = FactoryBot.build_stubbed(:claim, :payment_information_requested, unpaid_reason: Faker::Lorem.paragraph)
    render Claims::Support::Claim::ResponsesComponent.new(claim:)
  end

  def with_payment_information_sent_claim
    claim = FactoryBot.build_stubbed(:claim, :payment_information_sent, unpaid_reason: Faker::Lorem.paragraph)
    render Claims::Support::Claim::ResponsesComponent.new(claim:)
  end

  def with_sampling_in_progress_claim
    claim = FactoryBot.build_stubbed(:claim, :audit_requested, sampling_reason: Faker::Lorem.paragraph)
    render Claims::Support::Claim::ResponsesComponent.new(claim:)
  end

  def with_sampling_provider_not_approved_claim
    claim = Claims::Claim.sampling_provider_not_approved.sample ||
      FactoryBot.build_stubbed(:claim,
                               :audit_requested,
                               status: :sampling_provider_not_approved)
    render Claims::Support::Claim::ResponsesComponent.new(claim:)
  end

  def with_sampling_not_approved_claim
    claim = Claims::Claim.sampling_not_approved.sample ||
      FactoryBot.build_stubbed(:claim,
                               :audit_requested,
                               status: :sampling_not_approved)
    render Claims::Support::Claim::ResponsesComponent.new(claim:)
  end

  def with_clawback_in_progress_claim
    claim = Claims::Claim.clawback_in_progress.sample ||
      FactoryBot.build_stubbed(:claim,
                               :audit_requested,
                               status: :clawback_in_progress)
    render Claims::Support::Claim::ResponsesComponent.new(claim:)
  end

  def with_clawback_requested_claim
    claim = Claims::Claim.clawback_requested.sample ||
      FactoryBot.build_stubbed(:claim,
                               :audit_requested,
                               status: :clawback_requested)
    render Claims::Support::Claim::ResponsesComponent.new(claim:)
  end

  def with_clawback_complete_claim
    claim = Claims::Claim.clawback_complete.sample ||
      FactoryBot.build_stubbed(:claim,
                               :audit_requested,
                               status: :clawback_complete)
    render Claims::Support::Claim::ResponsesComponent.new(claim:)
  end
end
