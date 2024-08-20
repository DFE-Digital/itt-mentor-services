class Claims::Payments::ClaimsController < Claims::ApplicationController
  skip_before_action :authenticate_user!

  before_action :skip_authorization
  before_action :validate_token
  before_action :set_payment

  def download
    send_data Claims::Claim::GenerateCSV.call(claims: @payment.claims), filename: "claims-#{Date.current}.csv"
  end

  private

  def validate_token
    @payment_id = Rails.application.message_verifier(:payment).verify(token_param)
  rescue ActiveSupport::MessageVerifier::InvalidSignature, ActionController::ParameterMissing
    render "errors/link_expired"
  end

  def token_param
    params.require(:token)
  end

  def set_payment
    @payment = Claims::Payment.find(@payment_id)
  end
end
