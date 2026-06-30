class Claims::UserResearch::ProviderClaimsController < Claims::ApplicationController
  VISIBLE_STATUSES = %w[
    sampling_in_progress
    sampling_provider_not_approved
    paid
  ].freeze

  STATUS_ORDER = Arel.sql(<<~SQL.squish).freeze
    CASE status
      WHEN 'sampling_in_progress'           THEN 1
      WHEN 'sampling_provider_not_approved' THEN 2
      WHEN 'paid'                           THEN 3
      ELSE 4
    END
  SQL

  skip_before_action :authenticate_user!

  before_action :skip_authorization
  before_action :redirect_unless_logged_in
  before_action :set_provider
  before_action :set_filtered_claims, only: :index

  helper_method :filter_form, :provider_status_text_for

  def index
    @audit_requested_count = @filtered_claims.where(status: "sampling_in_progress").count
    @pagy, @claims = pagy(@filtered_claims)
  end

  def reset_demo
    Claims::UserResearch::ProviderClaimsDemoReset.call
    redirect_to claims_user_research_provider_claims_path, flash: {
      heading: "Demo data reset",
    }
  end

  def show
    @claim = claims_scope.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    head :not_found
  end

  private

  def redirect_unless_logged_in
    return if current_provider.present?

    redirect_to claims_root_path
  end

  def set_provider
    @provider = current_provider
  end

  def set_filtered_claims
    @filtered_claims = Claims::ClaimsQuery.call(params: filter_form.query_params)
      .where(provider_id: prototype_provider_ids)
      .where(status: VISIBLE_STATUSES)
      .reorder(STATUS_ORDER)
  end

  def filter_form
    @filter_form ||= Claims::Support::Claims::FilterForm.new(filter_params)
  end

  def provider_status_text_for(claim)
    return "Amended" if claim.sampling_provider_not_approved?
    return "Approved" if claim.paid?

    Claims::Claim.human_attribute_name("status.#{claim.status}")
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
    ).with_defaults(index_path: claims_user_research_provider_claims_path)
  end

  def claims_scope
    Claims::Claim.not_draft_status.includes(
      :claim_window,
      :provider,
      :academic_year,
      :support_user,
      mentor_trainings: :mentor,
      school: :region,
    ).where(provider_id: prototype_provider_ids)
  end

  def prototype_provider_ids
    @prototype_provider_ids ||= Claims::Provider.where(name: @provider.name).select(:id)
  end

  def current_provider
    @current_provider ||= prototype.provider_for(code: session[:provider_research_code])
  end

  def prototype
    @prototype ||= Claims::UserResearch::ProviderClaimsPrototype.new
  end
end
