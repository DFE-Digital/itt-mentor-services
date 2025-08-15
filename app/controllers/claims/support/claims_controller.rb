class Claims::Support::ClaimsController < Claims::Support::ApplicationController
  before_action :set_claim, only: %i[show]
  before_action :authorize_claim
  helper_method :filter_form
  before_action :store_filter_params, only: %i[index]
  before_action :set_filtered_claims, only: %i[index download_csv]

  def index
    @pagy, @claims = pagy(@filtered_claims)
    @schools = Claims::School.all
    @providers = Claims::Provider.private_beta_providers
    @academic_years = AcademicYear.where(id: Claims::ClaimWindow.select(:academic_year_id)).order_by_date
  end

  def show
    claim_activities = Claims::ClaimActivitiesForClaimQuery.call(claim: @claim)
    @pagy, @claim_activities = pagy(claim_activities)
    @claim_activities = claim_activities.decorate
  end

  def download_csv
    csv_data = Claims::Claim::GenerateCSV.call(claims: @filtered_claims)

    send_data csv_data, filename: "claims-#{Date.current}.csv", type: "text/csv", disposition: "attachment"
  end

  private

  def set_filtered_claims
    @filtered_claims = Claims::ClaimsQuery.call(params: filter_form.query_params)
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
    ).with_defaults(index_path:)
  end

  def set_claim
    @claim = Claims::Claim.includes(mentor_trainings: :mentor).find(params.require(:id))
  end

  def authorize_claim
    authorize @claim || Claims::Claim
  end

  def index_path
    claims_support_claims_path
  end

  def store_filter_params
    session["claims_filter_params"] = { claims_support_claims_filter_form: filter_params.to_h }
  end
end
