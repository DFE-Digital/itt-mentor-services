class Claims::ResetDatabase < ApplicationService
  def call
    return if HostingEnvironment.env.production?

    ActiveRecord::Base.transaction do
      Claims::Claim.destroy_all
      Claims::MentorMembership.destroy_all

      Claims::GrantConditionsAcceptance.delete_all
    end
  end
end
