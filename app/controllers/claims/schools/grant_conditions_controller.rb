class Claims::Schools::GrantConditionsController < Claims::ApplicationController
  include Claims::BelongsToSchool

  before_action :authorize_grant_conditions

  def show; end

  def update
    Claims::School::AcceptGrantConditions.call(school: @school, user: current_user)

    redirect_to claims_school_claims_path
  end

  private

  def authorize_grant_conditions
    authorize [:grant_conditions, @school]
  end
end
