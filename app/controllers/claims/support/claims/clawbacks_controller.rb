class Claims::Support::Claims::ClawbacksController < Claims::Support::ApplicationController
  append_pundit_namespace :claims

  before_action :set_filtered_claims, only: %i[index]
  before_action :set_claim, only: %i[show]
  before_action :authorize_claims

  helper_method :filter_form

  def index
    @pagy, @claims = pagy(
      @filtered_claims.where(status: Claims::Claim::CLAWBACK_STATUSES),
    )
  end

  def show
    claim_activities = Claims::ClaimActivitiesForClaimQuery.call(claim: @claim)
    @pagy, @claim_activities = pagy(claim_activities)
    @claim_activities = claim_activities.decorate
  end

  def new
    @clawback_requested_claims = Claims::Claim.clawback_requested

    unless policy(Claims::Clawback).create?
      render "new_not_permitted"
    end
  end

  def create
    Claims::Clawback::CreateAndDeliver.call(current_user:)

    redirect_to claims_support_claims_clawbacks_path, flash: { success: true, heading: t(".success") }
  end

  private

  def set_filtered_claims
    @filtered_claims = Claims::ClaimsQuery.call(params: filter_form.query_params)
  end

  def filter_form
    Claims::Support::Claims::FilterForm.new(filter_params)
  end

  def set_claim
    @claim = Claims::Claim.find(params.require(:id))
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
    claims_support_claims_clawbacks_path
  end

  def authorize_claims
    authorize [:clawbacks, set_filtered_claims]
  end
end
