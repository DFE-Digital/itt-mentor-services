class Claims::Sampling::CreateAndDeliver < ApplicationService
  def initialize(current_user:, claims:, csv_data:)
    @current_user = current_user
    @claims = claims
    @csv_data = csv_data
  end

  attr_reader :current_user, :claims, :csv_data

  def call
    claims.group_by(&:provider).each do |provider, provider_claims|
      ActiveRecord::Base.transaction do |transaction|
        provider_claims.each do |claim|
          Claims::Claim::Sampling::InProgress.call(claim:, sampling_reason: sampling_reason(claim))
        end

        provider_sampling = Claims::ProviderSampling.create!(provider:, claims: provider_claims, sampling:, csv_file: File.open(csv_for_provider(provider_claims, provider.name).to_io))

        transaction.after_commit do
          Claims::ProviderMailer.sampling_checks_required(provider_sampling).deliver_later
        end
      end
    end

    Claims::ClaimActivity.create!(action: :sampling_uploaded, user: current_user, record: sampling)
  end

  private

  def csv_for_provider(claims, provider_name)
    Claims::Sampling::GenerateCSVFile.call(claims:, provider_name:)
  end

  def sampling
    @sampling ||= Claims::Sampling.new
  end

  def sampling_reason(claim)
    csv_data.find { |csv_data| csv_data["claim_reference"] == claim.reference }["sample_reason"]
  end
end
