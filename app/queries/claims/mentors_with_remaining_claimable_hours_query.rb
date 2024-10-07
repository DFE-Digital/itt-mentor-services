class Claims::MentorsWithRemainingClaimableHoursQuery < ApplicationQuery
  def call
    @claim = params.fetch(:claim)
    @provider = params.fetch(:provider)
    @school = params.fetch(:school)

    scope = school.mentors.order_by_full_name

    remaining_claimable_hours_condition(scope)
  end

  private

  attr_reader :claim, :provider, :school

  def remaining_claimable_hours_condition(scope)
    mentor_with_claimable_hours = scope.filter do |mentor|
      training_allowance_for(mentor).available?
    end

    scope.where(id: mentor_with_claimable_hours)
  end

  def training_allowance_for(mentor)
    Claims::TrainingAllowance.new(mentor:, provider:, academic_year:)
  end

  def academic_year
    claim.claim_window.academic_year
  end
end
