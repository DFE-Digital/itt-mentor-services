class Claims::Support::SchoolsController < Claims::Support::ApplicationController
  def index
    @schools = Claims::School.includes(:gias_school).order("gias_schools.name ASC")
  end

  def show
    @school = Claims::School.find(params.require(:id))
  end
end
