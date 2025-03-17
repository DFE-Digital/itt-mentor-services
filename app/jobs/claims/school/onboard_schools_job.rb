class Claims::School::OnboardSchoolsJob < ApplicationJob
  queue_as :default

  def perform(school_ids:)
    school_ids.each do |school_id|
      school = School.find(school_id)
      Claims::Eligibility.find_or_create_by!(
        school:,
        claim_window:,
      )
    end
  end

  private

  def claim_window
    Claims::ClaimWindow.current
  end
end
