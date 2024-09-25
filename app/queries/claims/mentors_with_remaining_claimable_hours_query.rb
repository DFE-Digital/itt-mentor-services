class Claims::MentorsWithRemainingClaimableHoursQuery < ApplicationQuery
  def call
    scope = params[:school].mentors.order_by_full_name

    remaining_claimable_hours_condition(scope)
  end

  private

  def remaining_claimable_hours_condition(scope)
    mentor_with_claimable_hours = scope.filter do |mentor|
      training_allowance_for(mentor).available?
    end

    scope.where(id: mentor_with_claimable_hours)
  end

  def training_allowance_for(mentor)
    Claims::TrainingAllowance.new(mentor:, provider: params[:provider], academic_year: Claims::ClaimWindow.current.academic_year)
  end
end
