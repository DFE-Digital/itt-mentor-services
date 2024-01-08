class Claims::Support::SchoolsController < Claims::Support::ApplicationController
  def index
    @schools = Claims::School.order(:name)
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
    if school.update(claims: true)
      redirect_to claims_support_schools_path
    else
      render :new
    end
  end

  private

  def school
    @school ||= School.find_by(urn: urn_param) || Claims::School.new
  end

  def urn_param
    params.dig(:selection, :urn) || params.dig(:school, :urn)
  end
end
