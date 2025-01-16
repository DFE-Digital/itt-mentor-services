require "csv"

class Claims::SamplingResponse::GenerateCSVFile < ApplicationService
  HEADERS = %w[
    claim_reference
    sampling_reason
    school_urn
    school_name
    school_postcode
    mentor_full_name
    mentor_hours_of_training
    claim_assured
    claim_not_assured_reason
  ].freeze

  def initialize(csv_content:, provider_name:)
    @csv_content = csv_content
    @provider_name = provider_name
  end

  def call
    CSV.open(file_name, "w", headers: true) do |csv|
      csv << HEADERS

      CSV.parse(csv_content.strip, headers: :first_row, return_headers: false) do |row|
        csv << [
          row["reference"],
          row["sampling_reason"],
          row["school_urn"],
          row["school_name"],
          row["school_postcode"],
          row["mentor_full_name"],
          row["mentor_hours_of_training"],
          row["claim_assured"],
          row["claim_not_assured_reason"],
        ]
      end

      csv
    end
  end

  private

  attr_reader :csv_content, :provider_name

  def file_name
    Rails.root.join("tmp/#{provider_name}-sampling-claims-response-#{Time.current}.csv")
  end
end
