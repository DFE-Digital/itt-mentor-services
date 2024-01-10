class Claims::Support::SchoolsController < Claims::Support::ApplicationController
  def index
    @schools = Claims::School.order(:name)
  end

  def show
    @school = Claims::School.find(params.require(:id))
  end

  def new
    @school_form = SchoolOnboardingForm.new
  end

  def check
    if school_form.valid?
      @school = school
    else
      render :new
    end
  end

  def create
    if school_form.onboard
      redirect_to claims_support_schools_path
    else
      render :new
    end
  end

  private

  def school_form
    @school_form ||= SchoolOnboardingForm.new(urn: urn_param, service: :claims)
  end

  def school
    @school ||= school_form.school.decorate
  end

  def urn_param
    params.dig(:school, :search_urn)
  end
end
