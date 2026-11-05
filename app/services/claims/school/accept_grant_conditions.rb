class Claims::School::AcceptGrantConditions < ApplicationService
  def initialize(school:, user:)
    @school = school
    @user = user
  end

  attr_reader :school, :user

  def call
    # Lock the school so concurrent acceptances for the same year don't both try to insert.
    school.with_lock do
      school.grant_conditions_acceptances
        .find_or_initialize_by(academic_year: school.grant_conditions_academic_year)
        .update!(accepted_by: user, accepted_at: Time.current)
    end
  end
end
