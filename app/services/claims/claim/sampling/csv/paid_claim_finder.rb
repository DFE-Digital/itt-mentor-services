require "csv"

class Claims::Claim::Sampling::CSV::PaidClaimFinder < ApplicationService
  def initialize(csv_upload:)
    @csv_upload = csv_upload
  end

  attr_reader :csv_upload

  def call
    claim_ids = []
    CSV.parse(csv_upload.read, headers: true) do |row|
      claim_ids << paid_claims.find_by!(reference: row["claim_reference"]).id
    end

    claim_ids
  end

  private

  def paid_claims
    return @paid_claims if @paid_claims.present?

    current_academic_year = AcademicYear.for_date(Date.current)

    @paid_claims = Claims::Claim.paid.joins(claim_window: :academic_year)
      .where(academic_years: { id: current_academic_year.id })
  end
end
