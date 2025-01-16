require "csv"

class Claims::Sampling::GenerateCSVFile < ApplicationService
  HEADERS = %w[
    claim_reference
    sampling_reason
    school_urn
    school_name
    school_postcode
    mentor_full_name
    mentor_hours_of_training
    claim_assured
    claim_not_assured_reason
  ].freeze

  def initialize(claims:, provider_name:)
    @claims = claims
    @provider_name = provider_name
  end

  def call
    CSV.open(file_name, "w", headers: true) do |csv|
      csv << HEADERS

      claims.each do |claim|
        claim.mentor_trainings.each do |mentor_training|
          csv << [
            claim.reference,
            claim.sampling_reason,
            claim.school_urn,
            claim.school_name,
            claim.school_postcode,
            mentor_training.mentor_full_name,
            mentor_training.hours_completed,
          ]
        end
      end

      csv
    end
  end

  private

  attr_reader :claims, :provider_name

  def file_name
    Rails.root.join("tmp/#{provider_name}-claims-require-auditing-#{Time.current}.csv")
  end
end
