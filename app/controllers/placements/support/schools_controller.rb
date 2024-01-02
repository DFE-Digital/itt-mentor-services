class Placements::Support::SchoolsController < Placements::Support::ApplicationController
  def new
    @school = Placements::School.new
  end

  def check
    if school.valid? && !school.placements?
      @school = school.decorate
    else
      school.errors.add(:urn, :taken) if school.placements?
      render :new
    end
  end

  def create
    school.placements = true
    if school.save
      redirect_to placements_support_organisations_path
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
          Placements::School.new
        else
          gias_school.school || gias_school.build_school
        end
      end
  end

  def urn_param
    params.dig(:gias_school, :urn) || params.dig(:school, :urn)
  end
end
