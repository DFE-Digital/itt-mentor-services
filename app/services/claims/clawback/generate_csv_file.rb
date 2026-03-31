require "csv"

class Claims::Clawback::GenerateCSVFile < ApplicationService
  HEADERS = %w[
    claim_reference
    school_urn
    school_name
    school_local_authority
    provider_name
    claim_amount
    clawback_amount
    school_type_of_establishment
    school_group
    claim_submission_date
    claim_status
  ].freeze

  def initialize(claim_ids:)
    @claim_ids = claim_ids
  end

  def call
    CSV.open(file_name, "w", headers: true) do |csv|
      csv << HEADERS

      ordered_claims.each do |claim|
        school = claim.school

        csv << [
          claim.reference,
          school.urn,
          school.name,
          school.local_authority_name,
          claim.provider_name,
          claim.amount,
          claim.total_clawback_amount,
          school.type_of_establishment,
          school.group,
          claim.submitted_at.iso8601,
          claim.status,
        ]
      end

      csv
    end
  end

  private

  attr_reader :claim_ids

  def ordered_claims
    Claims::Claim.where(id: claim_ids)
                 .includes(:provider, :mentor_trainings, school: :region)
                 .order(:reference)
  end

  def file_name
    Rails.root.join("tmp/clawbacks_for_payer.csv")
  end
end
