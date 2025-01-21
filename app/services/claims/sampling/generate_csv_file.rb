require "csv"

class Claims::Sampling::GenerateCSVFile < ApplicationService
  HEADERS = %w[
    claim_reference
    school_urn
    school_name
    school_local_authority
    school_type_of_establishment
    school_group
    claim_submission_date
    mentor_full_name
    mentor_hours_of_training
    claim_accepted
    rejection_reason
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
            claim.school_urn,
            claim.school_name,
            claim.school.local_authority_name,
            claim.school.type_of_establishment,
            claim.school.group,
            claim.submitted_at.iso8601,
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
    Rails.root.join("tmp/quality_assurance_for_#{parameterised_provider_name}.csv")
  end

  def parameterised_provider_name
    provider_name.parameterize(separator: "_")
  end
end
