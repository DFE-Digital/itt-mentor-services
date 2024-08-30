require "csv"

class Claims::GenerateClaimsCSV
  include ServicePattern

  HEADERS = %w[claim_reference urn school_name local_authority claim_amount establishment_type date_submitted].freeze

  def initialize(claims:)
    @claims = claims
  end

  def call
    CSV.generate(headers: true) do |csv|
      csv << HEADERS

      claims.each do |claim|
        csv << [
          claim.reference,
          claim.school.urn,
          claim.school.name,
          claim.school.local_authority_name,
          claim.amount.format(symbol: false, decimal_mark: ".", no_cents: false),
          claim.school.group,
          claim.submitted_at&.iso8601,
        ]
      end
    end
  end

  private

  attr_reader :claims
end
