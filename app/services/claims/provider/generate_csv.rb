require "csv"

class Claims::Provider::GenerateCSV < ApplicationService
  HEADERS = %w[school_name school_urn school_post_code mentor_full_name hours_of_training claim_assured claim_assured_reason].freeze

  def initialize(provider:, academic_year:)
    @provider = provider
    @academic_year = academic_year
  end

  def call
    CSV.generate(headers: true) do |csv|
      csv << HEADERS

      mentor_trainings.each do |mentor_training|
        csv << [
          mentor_training.school_name,
          mentor_training.school_urn,
          mentor_training.school_postcode,
          mentor_training.mentor_full_name,
          mentor_training.total_hours_completed,
          # claim_assured,
          # claim_assured_reason,
        ]
      end
    end
  end

  private

  attr_reader :provider, :academic_year

  def mentor_trainings
    Claims::MentorTraining
      .joins(:mentor, :provider, claim: %i[school academic_year])
      .where(providers: { id: provider.id })
      .where(academic_years: { id: academic_year.id })
      .where(claims: { status: "submitted" })
      .group("schools.name", "schools.urn", "schools.postcode", "mentors.id")
      .select(
        "schools.name AS school_name",
        "schools.urn AS school_urn",
        "schools.postcode AS school_postcode",
        "mentors.id AS mentor_id",
        "CONCAT(mentors.first_name, ' ', mentors.last_name) AS mentor_full_name",
        "SUM(mentor_trainings.hours_completed) AS total_hours_completed",
      )
      .order("schools.name", "mentors.first_name", "mentors.last_name")
  end
end
