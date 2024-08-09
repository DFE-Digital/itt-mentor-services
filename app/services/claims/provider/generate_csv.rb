require "csv"

class Claims::Provider::GenerateCsv
  include ServicePattern

  HEADERS = %w[school_name school_urn school_post_code mentor_full_name hours_of_training claim_assured claim_assured_reason].freeze

  def initialize(provider:, academic_year:)
    @provider = provider
    @academic_year = academic_year
  end

  def call
    CSV.generate(headers: true) do |csv|
      csv << HEADERS

      mentor_trainings.group_by { |training| training.claim.school }
        .sort_by { |school, _school_mentor_trainings| school.name }
        .each do |school, school_mentor_trainings|
        school_mentor_trainings.group_by(&:mentor)
          .sort_by { |mentor, _trainings| mentor.full_name }
          .each do |mentor, trainings|
          csv << [
            school.name,
            school.urn,
            school.postcode,
            mentor.full_name,
            trainings.pluck(:hours_completed).sum,
            # claim_assured,
            # claim_assured_reason,
          ]
        end
      end
    end
  end

  private

  attr_reader :provider, :academic_year

  def mentor_trainings
    Claims::MentorTraining.includes(:mentor, :provider, claim: %i[school academic_year])
      .where(provider: { id: provider.id })
      .where(academic_year: { id: academic_year.id })
      .where(claim: { status: "submitted" })
  end
end
