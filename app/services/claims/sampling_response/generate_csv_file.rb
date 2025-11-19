require "csv"

class Claims::SamplingResponse::GenerateCSVFile < ApplicationService
  HEADERS = %w[
    claim_reference
    school_urn
    school_name
    school_local_authority
    school_type_of_establishment
    school_group
    provider_name
    claim_submission_date
    mentor_full_name
    mentor_hours_of_training
    claim_accepted
    rejection_reason
  ].freeze

  def initialize(csv_content:, provider_name:)
    @csv_content = csv_content
    @provider_name = provider_name
  end

  def call
    CSV.open(file_name, "w", headers: true) do |csv|
      csv << HEADERS

      CSV.parse(csv_content.strip, headers: :first_row, return_headers: false, encoding: "iso-8859-1:utf-8") do |row|
        csv << [
          row["claim_reference"],
          row["school_urn"],
          row["school_name"],
          row["school_local_authority"],
          row["school_type_of_establishment"],
          row["school_group"],
          row["provider_name"],
          row["claim_submission_date"],
          row["mentor_full_name"],
          row["mentor_hours_of_training"],
          row["claim_accepted"],
          row["rejection_reason"],
        ]
      end

      csv
    end
  end

  private

  attr_reader :csv_content, :provider_name

  def file_name
    Rails.root.join("tmp/quality_assurance_for_#{parameterised_provider_name}_response.csv")
  end

  def parameterised_provider_name
    provider_name.parameterize(separator: "_")
  end
end
