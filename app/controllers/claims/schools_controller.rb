class Claims::SchoolsController < ApplicationController
  before_action :redirect_to_school_when_belongs_to_one_school, only: :index

  def index
    @schools = current_user.schools
  end

  def show
    @school = Claims::School.find(params.require(:id))
  end

  private

  def redirect_to_school_when_belongs_to_one_school
    if current_user.schools.one?
      redirect_to claims_school_path(current_user.schools.first)
    end
  end
end
