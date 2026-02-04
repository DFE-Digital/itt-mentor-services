class Claims::Support::Claims::SamplingsController < Claims::Support::ApplicationController
  before_action :skip_authorization
  before_action :set_filtered_claims, only: %i[index]
  before_action :set_claim, except: %i[index]
  helper_method :filter_form

  def index
    @pagy, @claims = pagy(
      @filtered_claims.where(status: %i[sampling_in_progress sampling_provider_not_approved]),
    )
  end

  def show
    claim_activities = Claims::ClaimActivitiesForClaimQuery.call(claim: @claim)
    @pagy, @claim_activities = pagy(claim_activities)
    @claim_activities = claim_activities.decorate
  end

  def confirm_approval; end

  def update
    @claim.status = :paid
    @claim.save!

    Claims::ClaimActivity.create!(action: :provider_approved_audit, user: current_user, record: @claim)

    redirect_to claims_support_claims_samplings_path, flash: {
      heading: t(".success_heading"),
    }
  end

  private

  def set_filtered_claims
    @filtered_claims = Claims::ClaimsQuery.call(params: filter_form.query_params)
  end

  def set_claim
    @claim = Claims::Claim.includes(mentor_trainings: :mentor).find(params.require(:id))
  end

  def filter_form
    Claims::Support::Claims::FilterForm.new(filter_params)
  end

  def filter_params
    params.fetch(:claims_support_claims_filter_form, {}).permit(
      :search,
      :search_school,
      :search_provider,
      :academic_year_id,
      "submitted_after(1i)",
      "submitted_after(2i)",
      "submitted_after(3i)",
      "submitted_before(1i)",
      "submitted_before(2i)",
      "submitted_before(3i)",
      :submitted_after,
      :submitted_before,
      provider_ids: [],
      school_ids: [],
      statuses: [],
      mentor_ids: [],
      support_user_ids: [],
      training_types: [],
      claim_window_ids: [],
    ).with_defaults(index_path:)
  end

  def index_path
    claims_support_claims_samplings_path
  end
end
