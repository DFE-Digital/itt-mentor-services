class Claims::Sampling::CreateAndDeliver < ApplicationService
  def initialize(current_user:, claims:)
    @current_user = current_user
    @claims = claims
  end

  attr_reader :current_user, :claims

  def call
    claims.group_by(&:provider).each do |provider, provider_claims|
      ActiveRecord::Base.transaction do |transaction|
        provider_claims.each do |claim|
          Claims::Sampling::FlagForSamplingJob.perform_now(claim)
        end

        provider_sampling = Claims::ProviderSampling.create!(provider:, claims: provider_claims, sampling:, csv_file: File.open(csv_for_provider.to_io))

        transaction.after_commit do
          Claims::ProviderMailer.sampling_checks_required(provider_sampling).deliver_later
        end
      end
    end

    Claims::ClaimActivity.create!(action: :sampling_uploaded, user: current_user, record: sampling)
  end

  private

  def csv_for_provider
    Claims::Sampling::GenerateCSVFile.call(claims:)
  end

  def sampling
    @sampling ||= Claims::Sampling.new
  end
end
