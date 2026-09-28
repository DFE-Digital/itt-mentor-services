require "csv"

class Claims::Claim::GenerateProviderCSV < ApplicationService
  HEADERS = %w[
    academic_year
    school_urn
    school_name
    claim_reference
    mentor_first_name
    mentor_last_name
    hours_claimed
  ].freeze

  def initialize(claims:)
    @claims = claims
  end

  def call
    CSV.generate(headers: true) do |csv|
      csv << HEADERS

      ordered_claims.each do |claim|
        claim.mentor_trainings.each do |mentor_training|
          csv << [
            claim.academic_year_name,
            claim.school_urn,
            claim.school_name,
            claim.reference,
            mentor_training.mentor.first_name,
            mentor_training.mentor.last_name,
            mentor_training.corrected_hours_completed,
          ]
        end
      end
    end
  end

  private

  attr_reader :claims

  def ordered_claims
    claims
      .reorder(nil)
      .joins(:school, claim_window: :academic_year)
      .includes(:school, claim_window: :academic_year, mentor_trainings: :mentor)
      .order("academic_years.starts_on", "schools.name", :reference)
  end
end
