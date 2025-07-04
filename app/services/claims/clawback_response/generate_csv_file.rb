require "csv"

class Claims::ClawbackResponse::GenerateCSVFile < ApplicationService
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

  def initialize(csv_content:)
    @csv_content = csv_content
  end

  def call
    CSV.open(file_name, "w", headers: true) do |csv|
      csv << HEADERS

      CSV.parse(csv_content.strip, headers: :first_row, return_headers: false) do |row|
        csv << [
          row["claim_reference"],
          row["school_urn"],
          row["school_name"],
          row["school_local_authority"],
          row["provider_name"],
          row["claim_amount"],
          row["clawback_amount"],
          row["school_type_of_establishment"],
          row["school_group"],
          row["claim_submission_date"],
          row["claim_status"],
        ]
      end

      csv
    end
  end

  private

  attr_reader :csv_content

  def file_name
    Rails.root.join("tmp/clawbacks_for_payer_response.csv")
  end
end
