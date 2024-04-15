require "csv"

class Claims::GenerateClaimsCsv
  include ServicePattern

  HEADERS = %w[reference urn school_name local_authority_name amount_to_pay type].freeze

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
        ]
      end
    end
  end

  private

  attr_reader :claims
end
