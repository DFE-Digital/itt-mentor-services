class Claims::Support::SchoolsController < Claims::Support::ApplicationController
  before_action :redirect_to_school_options, only: :check, if: -> { javascript_disabled? }
  before_action :set_school, only: %i[show remove_grant_conditions_acceptance_check remove_grant_conditions_acceptance]
  before_action :authorize_school

  def index
    @pagy, @schools = pagy(schools.order_by_name)
  end

  def show; end

  def new
    @school_form = if params[:school].present?
                     school_form
                   else
                     SchoolOnboardingForm.new
                   end
  end

  def remove_grant_conditions_acceptance_check; end

  def remove_grant_conditions_acceptance
    @school.update!(claims_grant_conditions_accepted_at: nil, claims_grant_conditions_accepted_by: nil)
    redirect_to claims_support_school_path(@school), flash: {
      heading: t(".success"),
    }
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
      redirect_to check_claims_support_schools_path(
        school: { id: school_params.fetch(:id), name: search_param },
      )
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
    school_form.save!
    redirect_to claims_support_schools_path, flash: {
      heading: I18n.t("claims.support.schools.create.organisation_added"),
    }
  end

  private

  def redirect_to_school_options
    redirect_to school_options_claims_support_schools_path(
      school: { search_param: },
    )
  end

  def school_form(javascript_disabled: false)
    @school_form ||= SchoolOnboardingForm.new(
      id: school_params[:id],
      service: :claims,
      javascript_disabled:,
    )
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

  def javascript_disabled?
    params.dig(:school, :name).nil? && school_params[:id].present?
  end

  def school_params
    params.require(:school).permit(:id, :search_param, :name)
  end

  def search_param
    school_params[:search_param] || school_params[:id]
  end

  def decorated_school_options
    @decorated_school_options ||= School.search_name_urn_postcode(
      search_param.downcase,
    ).map(&:decorate)
  end

  def set_school
    @school = Claims::School.find(params.require(:id)).decorate
  end

  def authorize_school
    authorize @school || Claims::School, policy_class: Claims::SchoolPolicy
  end
end
