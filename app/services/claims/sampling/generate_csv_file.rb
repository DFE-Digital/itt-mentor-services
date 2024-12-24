require "csv"

class Claims::Sampling::GenerateCSVFile < ApplicationService
  HEADERS = %w[
    claim_reference
    sampling_reason
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
          claim.sampling_reason,
        ]
      end

      csv
    end
  end

  private

  attr_reader :claims

  def file_name
    Rails.root.join("tmp/sampling-claims-#{Time.current}.csv")
  end
end
