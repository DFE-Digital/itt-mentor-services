class Placements::Support::SchoolsController < Placements::Support::ApplicationController
  def new
    @school = Placements::School.new
  end

  def check
    if school.valid? && !school.placements?
      @school = school.decorate
    else
      school.errors.add(:urn, :already_added, school_name: school.name) if school.placements?
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

  def show
    @school = Placements::School.find(params[:id])&.decorate
  end

  private

  def school
    @school ||= School.find_by(urn: urn_param) || Placements::School.new
  end

  def urn_param
    params.dig(:selection, :urn) || params.dig(:school, :urn)
  end
end
