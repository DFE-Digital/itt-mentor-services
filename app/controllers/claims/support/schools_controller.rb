class Claims::Support::SchoolsController < Claims::Support::ApplicationController
  def index
    @schools = Claims::School.includes(:gias_school).order("gias_schools.name ASC")
  end

  def show
    @school = Claims::School.find(params.require(:id))
  end

  def new
    @school = Claims::School.new
  end

  def check
    if school.valid?
      @school = school.decorate
    else
      render :new
    end
  end

  def create
    if school.update(claims: true)
      redirect_to claims_support_schools_path
    else
      render :new
    end
  end

  private

  def school
    @school ||= School.find_by(gias_school:, claims: false) || Claims::School.new(gias_school:)
  end

  def gias_school
    @gias_school ||= GiasSchool.find_by(urn: urn_param)
  end

  def urn_param
    params.dig(:gias_school, :urn) || params.dig(:school, :urn)
  end
end
