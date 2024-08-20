class Claims::Payment::Claim::GenerateCSVFile < ApplicationService
  def initialize(claims:)
    @claims = claims
  end

  def call
    CSV.open(Rails.root.join("tmp", "payment_claims.csv"), "w+") do |csv|
      csv << ["1", "2", "3"]
    end
  end

  private

  attr_reader :claims
end
