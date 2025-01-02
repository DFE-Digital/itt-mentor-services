require "csv"

class Claims::Clawback::GenerateCSVFile < ApplicationService
  HEADERS = %w[
    claim_reference
    school_urn
    school_name
    school_local_authority
    school_type_of_establishment
    school_group
    claim_submission_date
    mentor_full_name
    reason_clawed_back
    hours_clawed_back
  ].freeze

  def initialize(claims:)
    @claims = claims
  end

  def call
    CSV.open(file_name, "w", headers: true) do |csv|
      csv << HEADERS

      claims.each do |claim|
        claim.mentor_trainings.not_assured.order_by_mentor_full_name.each do |mentor_training|
          csv << [
            claim.reference,
            claim.school.urn,
            claim.school_name,
            claim.school.local_authority_name,
            claim.school.type_of_establishment,
            claim.school.group,
            claim.submitted_at.iso8601,
            mentor_training.mentor_full_name,
            mentor_training.reason_clawed_back,
            mentor_training.hours_clawed_back,
          ]
        end
      end

      csv
    end
  end

  private

  attr_reader :claims

  def file_name
    Rails.root.join("tmp/clawback-claims-#{Time.current}.csv")
  end
end
