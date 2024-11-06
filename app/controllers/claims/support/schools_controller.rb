class Claims::Support::SchoolsController < Claims::Support::ApplicationController
  before_action :set_school, only: %i[show remove_grant_conditions_acceptance_check remove_grant_conditions_acceptance]
  before_action :authorize_school

  def index
    @pagy, @schools = pagy(schools)
  end

  def show; end

  def remove_grant_conditions_acceptance_check; end

  def remove_grant_conditions_acceptance
    @school.update!(claims_grant_conditions_accepted_at: nil, claims_grant_conditions_accepted_by: nil)
    redirect_to claims_support_school_path(@school), flash: {
      heading: t(".success"),
    }
  end

  private

  def redirect_to_school_options
    redirect_to school_options_claims_support_schools_path(
      school: { search_param: },
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

  def set_school
    @school = Claims::School.find(params.require(:id)).decorate
  end

  def authorize_school
    authorize @school || Claims::School, policy_class: Claims::SchoolPolicy
  end
end
