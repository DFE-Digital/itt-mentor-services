class Claims::Providers::ClaimsController < Claims::Providers::ApplicationController
  before_action :set_provider
  before_action :set_claim, only: :show
  before_action :authorize_claim, only: :show
  before_action :authorize_claims, only: :index

  helper_method :filter_form

  def index
    @schools = Claims::School.where(id: claims.select(:school_id)).order_by_name
    query = Claims::Providers::ClaimsQuery.call(claims:, params: filter_form.query_params)
    @pagy, @claims = pagy(query)
  end

  def show; end

  private

  def claims
    policy_scope(Claims::Claim.where(provider: @provider))
      .includes(:school, :provider, :claim_window, mentor_trainings: :mentor)
      .not_draft_status
      .provider_visible
      .order_created_at_desc
  end

  def filter_form
    @filter_form ||= Claims::Providers::Claims::FilterForm.new(filter_params.merge(index_path: claims_provider_claims_path(@provider)))
  end

  def filter_params
    params.fetch(:claims_providers_claims_filter_form, {}).permit(school_ids: [])
  end

  def set_claim
    @claim = claims.find(params.require(:id))
  end

  def authorize_claims
    authorize Claims::Claim
  end

  def authorize_claim
    authorize @claim
  end
end
