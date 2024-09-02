class Claims::ResetDatabase < ApplicationService
  def call
    return if HostingEnvironment.env.production?

    ActiveRecord::Base.transaction do
      Claims::Claim.destroy_all
      Claims::MentorMembership.destroy_all

      Claims::School.update_all(
        claims_grant_conditions_accepted_at: nil,
        claims_grant_conditions_accepted_by_id: nil,
      )
    end
  end
end
