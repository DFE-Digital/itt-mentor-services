class Claims::School::AcceptGrantConditions
  include ServicePattern

  def initialize(school:, user:)
    @school = school
    @user = user
  end

  attr_reader :school, :user

  def call
    school.update(
      claims_grant_conditions_accepted_at: Time.current,
      claims_grant_conditions_accepted_by: user,
    )
  end
end
