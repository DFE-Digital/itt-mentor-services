class Claims::Schools::ClaimsController < Claims::ApplicationController
  include Claims::BelongsToSchool

  before_action :has_school_accepted_grant_conditions?
  before_action :set_claim, only: %i[show check confirmation submit edit update rejected create_revision remove destroy]
  before_action :authorize_claim
  before_action :get_valid_revision, only: :check

  helper_method :claim_provider_form

  def index
    @pagy, @claims = pagy(@school.claims.active.order_created_at_desc)
  end

  def new; end

  def create
    if claim_provider_form.save
      redirect_to new_claims_school_claim_mentors_path(@school, claim_provider_form.claim)
    else
      render :new
    end
  end

  def create_revision
    revision = Claims::Claim::CreateRevision.call(claim: @claim)
    redirect_to edit_claims_school_claim_path(@school, revision)
  end

  def show; end

  def check
    last_mentor_training = @claim.mentor_trainings.order_by_mentor_full_name.last
    Claims::Claim::Review.call(claim: @claim)

    @back_path = edit_claims_school_claim_mentor_training_path(
      @school,
      @claim,
      last_mentor_training,
    )
    Claims::Claim::RemoveEmptyMentorTrainingHours.call(claim: @claim)
  end

  def edit; end

  def update
    if claim_provider_form.save
      redirect_to claim_provider_form.update_success_path
    else
      render :edit
    end
  end

  def confirmation; end

  def submit
    return redirect_to rejected_claims_school_claim_path unless @claim.valid_mentor_training_hours?

    Claims::Claim::Submit.call(claim: @claim, user: current_user)

    redirect_to confirmation_claims_school_claim_path(@school, @claim)
  end

  def rejected; end

  def remove; end

  def destroy
    @claim.destroy!

    redirect_to claims_school_claims_path(@school, @claim), flash: {
      heading: t(".success"),
    }
  end

  private

  def claim_params
    params.require(:claims_claim_provider_form)
      .permit(:id, :provider_id)
      .merge(default_params)
  end

  def default_params
    { school: @school, current_user:, claim_window: Claims::ClaimWindow.current }
  end

  def claim_provider_form
    @claim_provider_form ||=
      if params[:claims_claim_provider_form].present?
        Claims::Claim::ProviderForm.new(claim_params)
      else
        Claims::Claim::ProviderForm.new(default_params.merge(id: claim_id))
      end
  end

  def set_claim
    @claim = @school.claims.find(claim_id)
  end

  def claim_id
    params[:claim_id] || params[:id]
  end

  def authorize_claim
    authorize @claim || Claims::Claim
  end

  def get_valid_revision
    revision = @claim.get_valid_revision

    redirect_to check_claims_school_claim_path(@school, revision) if revision != @claim
  end
end
