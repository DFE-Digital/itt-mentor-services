class Claims::SchoolsController < ApplicationController
  before_action :redirect_to_school_when_belongs_to_one_school, only: :index
  before_action :set_school, only: [:show]

  def index
    @schools = current_user.schools
  end

  def show; end

  private

  def redirect_to_school_when_belongs_to_one_school
    if current_user.schools.one?
      redirect_to claims_school_path(current_user.schools.first)
    end
  end

  def set_school
    @school = School.find(params[:id])
  end
end
