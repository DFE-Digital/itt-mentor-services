class Claims::SchoolsController < Claims::ApplicationController
  before_action :redirect_to_school_claims_when_belongs_to_one_school, only: :index
  before_action :authorize_school
  before_action :set_school, only: :show
  before_action :has_school_accepted_grant_conditions?, only: :show

  def index
    @schools = policy_scope(Claims::School)
  end

  def show; end

  private

  def set_school
    @school = Claims::School.find(params.require(:id)).decorate
  end

  def redirect_to_school_claims_when_belongs_to_one_school
    if policy_scope(Claims::School).one?
      redirect_to claims_school_claims_path(current_user.schools.first)
    end
  end

  def authorize_school
    authorize @school || Claims::School
  end
end
