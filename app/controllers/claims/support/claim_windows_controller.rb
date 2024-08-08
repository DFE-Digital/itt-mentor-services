class Claims::Support::ClaimWindowsController < Claims::Support::ApplicationController
  before_action :set_claim_window, only: %i[show edit edit_check update remove destroy]
  before_action :authorize_claim_window

  helper_method :claim_window_form

  def index
    @claim_windows = Claims::ClaimWindow.order(starts_on: :desc)
  end

  def new; end

  def new_check
    render :new unless claim_window_form.valid?
  end

  def create
    claim_window_form.save!

    redirect_to claims_support_claim_windows_path, flash: { success: t(".success") }
  end

  def show; end

  def edit; end

  def edit_check
    render :edit unless claim_window_form.valid?
  end

  def update
    claim_window_form.save!

    redirect_to claims_support_claim_window_path(@claim_window), flash: { success: t(".success") }
  end

  def remove; end

  def destroy
    @claim_window.discard!

    redirect_to claims_support_claim_windows_path, flash: { success: t(".success") }
  end

  private

  def claim_window_form_params
    params.fetch(:claims_claim_window_form, {}).permit(:starts_on, :ends_on, :academic_year_id)
  end

  def set_claim_window
    @claim_window = Claims::ClaimWindow.find(params.require(:id))
  end

  def authorize_claim_window
    authorize @claim_window || Claims::ClaimWindow
  end

  def claim_window_form
    @claim_window_form ||= Claims::ClaimWindowForm.new(id: params[:id], **claim_window_form_params)
  end
end
