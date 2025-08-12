class Claims::Support::ManuallyOnboardedSchoolsController < Claims::Support::ApplicationController
  before_action :skip_authorization

  def index
    @pagy, @manually_onboarded_schools = pagy(
      Claims::School.where.not(manually_onboarded_by_id: nil).order_by_name,
    )
  end
end
