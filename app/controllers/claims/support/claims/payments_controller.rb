class Claims::Support::Claims::PaymentsController < Claims::Support::ApplicationController
  append_pundit_namespace :claims

  before_action :authorize_claims

  helper_method :filter_form, :submitted_claims, :payment_in_progress_claims

  def index
    @pagy, @claims = pagy(filtered_claims)
  end

  private

  def filtered_claims
    @filtered_claims ||= Claims::ClaimsQuery.call(params: filter_form.query_params)
                                            .where(status: Claims::Claim::PAYMENT_ACTIONABLE_STATUSES)
                                            .reorder(payment_in_progress_at: :asc)
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
    )
  end

  def authorize_claims
    authorize [:payments, filtered_claims]
  end

  def submitted_claims
    @submitted_claims ||= Claims::Claim.submitted
  end

  def payment_in_progress_claims
    @payment_in_progress_claims ||= Claims::Claim.payment_in_progress
  end
end
