require "csv"

class Claims::PaymentResponse::GenerateCSVFile < ApplicationService
  HEADERS = %w[
    claim_reference
    school_urn
    school_name
    school_local_authority
    claim_amount
    clawback_amount
    school_type_of_establishment
    school_group
    claim_submission_date
    claim_status
    claim_unpaid_reason
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
          row["claim_amount"],
          row["clawback_amount"],
          row["school_type_of_establishment"],
          row["school_group"],
          row["claim_submission_date"],
          row["claim_status"],
          row["claim_unpaid_reason"],
        ]
      end

      csv
    end
  end

  private

  attr_reader :csv_content

  def file_name
    Rails.root.join("tmp/payments_for_payer_response.csv")
  end
end
