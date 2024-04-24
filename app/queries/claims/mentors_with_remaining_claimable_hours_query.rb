class Claims::MentorsWithRemainingClaimableHoursQuery < ApplicationQuery
  def call
    scope = params[:school].mentors.order_by_full_name

    remaining_claimable_hours_condition(scope)
  end

  private

  def remaining_claimable_hours_condition(scope)
    mentor_with_claimable_hours = scope.filter do |mentor|
      Claims::Mentor::CalculateRemainingMentorTrainingHoursForProvider.call(mentor:, provider: params[:provider], claim: params[:claim]).positive?
    end

    scope.where(id: mentor_with_claimable_hours)
  end
end
