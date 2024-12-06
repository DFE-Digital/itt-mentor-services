require "csv"

class Claims::Claim::Sampling::CSV::PaidClaimFinder < ApplicationService
  def initialize(csv_upload:)
    @csv_upload = csv_upload
  end

  attr_reader :csv_upload

  def call
    raise InvalidFileError unless csv_upload.content_type == "text/csv"

    claim_ids = []
    CSV.parse(csv_upload.read, headers: true) do |row|
      claim_ids << paid_claims.find_by!(reference: row["claim_reference"]).id
    end

    claim_ids
  end

  private

  def paid_claims
    @paid_claims ||= Claims::Claim.paid_for_current_academic_year
  end
end

class InvalidFileError < StandardError; end
