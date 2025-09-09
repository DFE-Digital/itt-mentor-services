class Claims::Schools::ClaimsController < Claims::ApplicationController
  include Claims::BelongsToSchool

  before_action :has_school_accepted_grant_conditions?
  before_action :set_claim, only: %i[show confirmation remove destroy]
  before_action :set_academic_year, only: :index
  before_action :authorize_claim

  helper_method :edit_attribute_path

  def index
    @current_academic_year_selected = @academic_year.current?
    @current_claim_window = Claims::ClaimWindow.current
    @previous_claim_window = Claims::ClaimWindow.previous
    academic_year_scope = AcademicYear.before_date(@current_claim_window&.academic_year&.starts_on || Date.current)
    @previous_academic_years = academic_year_scope.where.associated(:claim_windows).distinct.order_by_date_desc.decorate
    @pagy, @claims = pagy(claims_for_academic_year)
  end

  def show; end

  def confirmation; end

  def rejected; end

  def remove; end

  def destroy
    @claim.destroy!

    redirect_to claims_school_claims_path(@school, @claim), flash: {
      heading: t(".success"),
    }
  end

  private

  def set_claim
    @claim = @school.claims.includes(mentor_trainings: :mentor).find(claim_id)
  end

  def claim_id
    params[:claim_id] || params[:id]
  end

  def authorize_claim
    authorize @claim || Claims::Claim.new(school: @school)
  end

  def edit_attribute_path(attribute)
    new_edit_claim_claims_school_claim_path(@school, @claim, step: attribute)
  end

  def set_academic_year
    @academic_year = if params[:academic_year_id].present?
                       AcademicYear.find(params[:academic_year_id])
                     else
                       AcademicYear.for_latest_claim_window
                     end
  end

  def claims_for_academic_year
    @school.claims.includes(:provider, :mentor_trainings)
    .joins(:academic_year)
    .where(academic_year: { id: @academic_year.id })
    .order_created_at_desc
  end
end
