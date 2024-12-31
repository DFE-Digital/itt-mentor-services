class Claims::Support::Claims::PaymentResponsesController < Claims::Support::ApplicationController
  append_pundit_namespace :claims

  before_action :authorize_claims_payments_response

  helper_method :claims_payment_response

  def new
    render "new_not_permitted" unless policy(claims_payment_response).update?
  end

  def check
    render "new" unless claims_payment_response.save
  end

  def update
    Claims::PaymentResponse::Process.call(payment_response: claims_payment_response, current_user:)

    redirect_to claims_support_claims_payments_path, flash: { success: true, heading: t(".success") }
  end

  private

  def authorize_claims_payments_response
    authorize claims_payment_response
  end

  def claims_payment_response_params
    params.fetch(:claims_payment_response, {}).permit(:csv_file).merge(user: current_user)
  end

  def claims_payment_response
    @claims_payment_response ||= params[:id] ? Claims::PaymentResponse.find(params[:id]) : Claims::PaymentResponse.new(claims_payment_response_params)
  end
end
