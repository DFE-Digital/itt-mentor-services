class Claims::Sampling::SendProviderRemindersJob < ApplicationJob
  queue_as :default

  def perform
    wait_time = 0.minutes

    provider_samplings.find_in_batches(batch_size: 100) do |batch|
      batch.each do |provider_sampling|
        provider_sampling.provider_users.each do |provider_user|
          Claims::ProviderMailer.resend_sampling_checks_required(provider_sampling, provider_user).deliver_later(wait: wait_time)
        end
      end

      wait_time += 1.minute
    end
  end

  private

  def outstanding_claims
    @outstanding_claims ||= Claims::Claim.sampling_in_progress
  end

  def provider_samplings
    @provider_samplings ||= Claims::ProviderSampling
                              .where(
                                id: Claims::ProviderSamplingClaim.where(claim: outstanding_claims)
                                                                 .select("DISTINCT ON (claim_id) provider_sampling_id"),
                              )
                              .order("provider_id, created_at DESC")
  end
end
