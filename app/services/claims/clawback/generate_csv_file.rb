require "csv"

class Claims::Clawback::GenerateCSVFile < ApplicationService
  HEADERS = %w[
    claim_reference
    school_urn
    school_name
    school_local_authority
    school_type_of_establishment
    clawback_amouht
    claim_submission_date
    claim_status
  ].freeze

  def initialize(claims:)
    @claims = claims
  end

  def call
    CSV.open(file_name, "w", headers: true) do |csv|
      csv << HEADERS

      claims.each do |claim|
        csv << [
          claim.reference,
          claim.school.urn,
          claim.school_name,
          claim.school.local_authority_name,
          claim.school.type_of_establishment,
          claim.total_clawback_amount,
          claim.submitted_at.iso8601,
          claim.status,
        ]
      end

      csv
    end
  end

  private

  attr_reader :claims

  def file_name
    Rails.root.join("tmp/clawback-claims-#{Time.current}.csv")
  end
end
