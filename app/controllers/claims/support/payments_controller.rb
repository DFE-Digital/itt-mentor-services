class Claims::Support::PaymentsController < Claims::ApplicationController
  before_action :set_claims, only: %i[index]
  before_action :authorize_payment

  def index; end

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
end
