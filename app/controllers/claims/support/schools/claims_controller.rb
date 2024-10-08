class Claims::Support::Schools::ClaimsController < Claims::Support::ApplicationController
  include Claims::BelongsToSchool

  before_action :set_claim, only: %i[check draft show edit update remove destroy rejected create_revision]
  before_action :authorize_claim
  before_action :get_valid_revision, only: :check

  helper_method :claim_provider_form

  def index
    @pagy, @claims = pagy(@school.claims.active.order_created_at_desc)
  end

  def new; end

  def show; end

  def remove; end

  def destroy
    @claim.destroy!

    redirect_to claims_support_school_claims_path(@school, @claim), flash: {
      heading: t(".success"),
    }
  end

  def create
    if claim_provider_form.save
      redirect_to new_claims_support_school_claim_mentors_path(@school, claim_provider_form.claim)
    else
      render :new
    end
  end

  def create_revision
    revision = Claims::Claim::CreateRevision.call(claim: @claim)
    redirect_to edit_claims_support_school_claim_path(@school, revision)
  end

  def check
    last_mentor_training = @claim.mentor_trainings.order_by_mentor_full_name.last
    Claims::Claim::Review.call(claim: @claim)

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
      redirect_to claim_provider_form.update_success_path
    else
      render :edit
    end
  end

  def draft
    return redirect_to rejected_claims_support_school_claim_path unless @claim.valid_mentor_training_hours?

    claim_was_draft = @claim.was_draft?
    success_message = claim_was_draft ? t(".update_success") : t(".add_success")

    if claim_was_draft
      Claims::Claim::UpdateDraft.call(claim: @claim)
    else
      Claims::Claim::CreateDraft.call(claim: @claim)
    end

    redirect_to claims_support_school_claims_path(@school), flash: {
      heading: success_message,
    }
  end

  def rejected; end

  private

  def claim_params
    params.require(:claims_support_claim_provider_form)
      .permit(:id, :provider_id)
      .merge(default_params)
  end

  def default_params
    { school: @school, current_user:, claim_window: Claims::ClaimWindow.current }
  end

  def claim_id
    params[:claim_id] || params[:id]
  end

  def set_claim
    @claim = @school.claims.find(claim_id)
  end

  def claim_provider_form
    @claim_provider_form ||=
      if params[:claims_support_claim_provider_form].present?
        Claims::Support::Claim::ProviderForm.new(claim_params)
      else
        Claims::Support::Claim::ProviderForm.new(default_params.merge(id: claim_id))
      end
  end

  def authorize_claim
    authorize @claim || Claims::Claim
  end

  def get_valid_revision
    revision = @claim.get_valid_revision

    redirect_to check_claims_support_school_claim_path(@school, revision) if revision != @claim
  end
end
