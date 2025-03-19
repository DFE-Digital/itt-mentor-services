class Claims::School::OnboardSchoolsJob < ApplicationJob
  queue_as :default

  def perform(school_ids:, claim_window_id: nil)
    @claim_window_id = claim_window_id

    school_ids.each do |school_id|
      school = School.find(school_id)
      school.update!(claims_service: true)

      Claims::Eligibility.find_or_create_by!(
        school:,
        claim_window:,
      )
    end
  end

  private

  attr_reader :claim_window_id

  def claim_window
    if claim_window_id
      Claims::ClaimWindow.find(claim_window_id)
    else
      Claims::ClaimWindow.current
    end
  end
end
