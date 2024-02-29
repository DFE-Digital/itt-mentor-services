require "csv"

class Claims::GenerateClaimsCsv
  include ServicePattern

  HEADERS = %w[school_name school_urn amount claim_reference_number].freeze

  def call
    CSV.generate(headers: true) do |csv|
      csv << HEADERS

      Claim.find_each do |claim|
        csv << [
          claim.school.name,
          claim.school.urn,
          claim.amount.format(symbol: false, decimal_mark: ".", no_cents: false),
          claim.reference,
        ]
      end
    end
  end
end
