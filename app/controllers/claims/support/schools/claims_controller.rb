class Claims::Support::Schools::ClaimsController < Claims::Support::ApplicationController
  include Claims::BelongsToSchool

  before_action :set_claim, only: %i[check draft show edit update remove destroy]
  before_action :authorize_claim
  helper_method :claim_provider_form

  def index
    @pagy, @claims = pagy(@school.claims.active.order_created_at_desc)
  end

  def new; end

  def show; end

  def remove; end

  def destroy
    @claim.destroy!

    redirect_to claims_support_school_claims_path(@school, @claim), flash: { success: t(".success") }
  end

  def create
    if claim_provider_form.save
      redirect_to new_claims_support_school_claim_mentor_path(@school, claim_provider_form.claim)
    else
      render :new
    end
  end

  def check
    last_mentor_training = @claim.mentor_trainings.order_by_mentor_full_name.last

    @back_path = edit_claims_support_school_claim_mentor_training_path(
      @school,
      @claim,
      last_mentor_training,
      params: {
        claims_support_claim_mentor_training_form: { hours_completed: last_mentor_training.hours_completed },
      },
    )
    Claims::Claim::RemoveEmptyMentorTrainingHours.call(claim: @claim)
  end

  def edit; end

  def update
    if claim_provider_form.save
      redirect_to check_claims_support_school_claim_path(@school, claim_provider_form.claim)
    else
      render :edit
    end
  end

  def draft
    success_message = @claim.draft? ? t(".update_success") : t(".add_success")
    Claims::Claim::CreateDraft.call(claim: @claim)

    redirect_to claims_support_school_claims_path(@school), flash: { success: success_message }
  end

  private

  def claim_params
    params.require(:claims_claim_provider_form)
      .permit(:id, :provider_id)
      .merge(default_params)
  end

  def default_params
    { school: @school, current_user: }
  end

  def claim_id
    params[:claim_id] || params[:id]
  end

  def set_claim
    @claim = @school.claims.find(claim_id)
  end

  def claim_provider_form
    @claim_provider_form ||=
      if params[:claims_claim_provider_form].present?
        Claims::Claim::ProviderForm.new(claim_params)
      else
        Claims::Claim::ProviderForm.new(default_params.merge(id: claim_id))
      end
  end

  def authorize_claim
    authorize @claim || Claims::Claim
  end
end
