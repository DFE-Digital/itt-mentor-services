class Claims::Support::Claims::SamplingsController < Claims::Support::ApplicationController
  before_action :skip_authorization
  before_action :set_filtered_claims, only: %i[index]
  helper_method :filter_form

  def index
    @pagy, @claims = pagy(
      @filtered_claims.where(status: %i[sampling_in_progress sampling_provider_not_approved]),
    )
  end

  def upload
    if paid_claims.present?
      render "upload_form"
    else
      render "can_not_upload"
    end
  end

  def process_upload
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
      academic_year_ids: [],
    ).with_defaults(index_path:)
  end

  def index_path
    claims_support_claims_samplings_path
  end

  def paid_claims
    current_academic_year = AcademicYear.for_date(Date.current)

    Claims::Claim.paid.joins(claim_window: :academic_year)
      .where(academic_years: { id: current_academic_year.id })
  end
end
