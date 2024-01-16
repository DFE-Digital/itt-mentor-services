class Claims::Support::SchoolsController < Claims::Support::ApplicationController
  def index
    @pagy, @schools = pagy(schools)
    @search_param = params[:name_or_postcode]
  end

  def show
    @school = Claims::School.find(params.require(:id)).decorate
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
      flash[:success] = I18n.t("claims.support.schools.create.organisation_added")
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

  def schools
    @schools ||= if params[:name_or_postcode].blank?
                   Claims::School.order(:name)
                 else
                   Claims::School.search_name_postcode(params[:name_or_postcode]).order(:name)
                 end
  end

  def urn_param
    params.dig(:school, :search_urn)
  end
end
