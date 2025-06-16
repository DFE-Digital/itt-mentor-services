class Claims::Support::ManuallyOnboardedSchoolsController < Claims::Support::ApplicationController
  before_action :skip_authorization

  def index
    @manually_onboarded_schools = Claims::School.where.not(manually_onboarded_by_id: nil)
  end
end
