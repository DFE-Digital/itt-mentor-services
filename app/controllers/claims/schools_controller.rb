class Claims::SchoolsController < ApplicationController
  before_action :redirect_to_school_claims_when_belongs_to_one_school, only: :index

  def index
    @schools = policy_scope(Claims::School)
  end

  def show
    @school = Claims::School.find(params.require(:id))&.decorate
  end

  private

  def redirect_to_school_claims_when_belongs_to_one_school
    if policy_scope(Claims::School).one?
      redirect_to claims_school_claims_path(current_user.schools.first)
    end
  end
end
