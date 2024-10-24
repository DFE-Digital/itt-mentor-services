class Claims::Support::PaymentsController < Claims::ApplicationController
  before_action :set_claims, only: %i[index]
  before_action :authorize_payment

  helper_method :filter_form

  def index; end

  def new
    @submitted_claims = Claims::Claim.submitted
  end

  def create
    Claims::Payment::CreateAndDeliver.call(current_user:)

    redirect_to claims_support_payments_path, flash: { heading: t(".success"), success: true }
  end

  private

  def set_claims
    @pagy, @claims = pagy(Claims::Claim.where(status: %i[payment_information_requested payment_information_sent]))
  end

  def authorize_payment
    authorize Claims::Payment
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
    )
  end
end
