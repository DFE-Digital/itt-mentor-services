class Placements::Support::SchoolsController < Placements::Support::ApplicationController
  before_action :redirect_to_school_options, only: :check, if: -> { javascript_disabled? }

  def new
    @school_form = SchoolOnboardingForm.new
  end

  def school_options
    render locals: {
      search_param:,
      schools: decorated_school_options,
      school_form: SchoolOnboardingForm.new,
    }
  end

  def check_school_option
    if school_form(javascript_disabled: true).valid?
      redirect_to check_placements_support_schools_path(school: { search_urn: urn_param })
    else
      render :school_options, locals: {
        search_param:,
        schools: decorated_school_options,
        school_form: school_form(javascript_disabled: true),
      }
    end
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
      flash[:success] = I18n.t("placements.support.schools.create.organisation_added")
      redirect_to placements_support_organisations_path
    else
      render :new
    end
  end

  def show
    @school = Placements::School.find(params[:id]).decorate
  end

  private

  def redirect_to_school_options
    redirect_to school_options_placements_support_schools_path(
      school: { search_param: school_params[:urn] },
    )
  end

  def school_form(javascript_disabled: false)
    @school_form ||= SchoolOnboardingForm.new(
      urn: urn_param,
      service: :placements,
      javascript_disabled:,
    )
  end

  def school
    @school ||= school_form.school.decorate
  end

  def urn_param
    params.dig(:school, :search_urn) || school_params[:urn]
  end

  def javascript_disabled?
    school_params[:search_urn].nil? && school_params[:urn].present?
  end

  def school_params
    params.require(:school).permit(:urn, :search_param, :search_urn)
  end

  def search_param
    school_params[:search_param] || params[:search_param]
  end

  def decorated_school_options
    @decorated_school_options ||= School.search_name_urn_postcode(
      search_param.downcase,
    ).map(&:decorate)
  end
end
