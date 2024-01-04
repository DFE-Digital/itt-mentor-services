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
    if school.valid? && !school.claims?
      @school = school.decorate
    else
      school.errors.add(:urn, :taken) if school.claims?
      render :new
    end
  end

  def create
    school.claims = true
    if school.save
      redirect_to claims_support_schools_path
    else
      render :new
    end
  end

  private

  def school
    @school ||=
      begin
        gias_school = GiasSchool.find_by(urn: urn_param)
        if gias_school.blank?
          Claims::School.new
        else
          gias_school.school || gias_school.build_school
        end
      end
  end

  def urn_param
    params.dig(:gias_school, :urn) || params.dig(:school, :urn)
  end
end
