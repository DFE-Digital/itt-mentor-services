class Claims::Support::Payments::ConfirmationsController < Claims::Support::ApplicationController
  before_action :authorize_confirmation

  def create
    Claims::Payment::ParseConfirmation.call(file: file_param)

    redirect_to claims_support_payments_path, flash: { heading: t(".success"), success: true }
  end

  private

  def file_param
    params.require(:file)
  end

  def authorize_confirmation
    authorize :confirmation, policy_class: Claims::Support::Payments::ConfirmationPolicy
  end

  def policy(record = nil)
    Claims::Support::Payments::ConfirmationPolicy.new(current_user, record)
  end
end
