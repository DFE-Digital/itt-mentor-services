class Claims::Support::ClaimWindowsController < Claims::Support::ApplicationController
  before_action :set_claim_window, only: %i[show edit edit_check update remove destroy]
  before_action :authorize_claim_window

  def index
    @claim_windows = Claims::ClaimWindow.order(starts_on: :desc)
  end

  def new
    @claim_window = if params[:claims_claim_window]
                      Claims::ClaimWindow.new(claim_window_params)
                    else
                      Claims::ClaimWindow.new
                    end
  end

  def new_check
    @claim_window = Claims::ClaimWindow::Build.call(claim_window_params:)

    render :new unless @claim_window.valid?
  end

  def create
    @claim_window = Claims::ClaimWindow::Build.call(claim_window_params:)
    @claim_window.save!

    redirect_to claims_support_claim_windows_path, flash: { success: "Claim window created" }
  end

  def show; end

  def edit
    if params[:claims_claim_window]
      @claim_window.assign_attributes(claim_window_params)
    end
  end

  def edit_check
    @claim_window = Claims::ClaimWindow::Build.call(claim_window: @claim_window, claim_window_params:)

    render :edit unless @claim_window.valid?
  end

  def update
    @claim_window = Claims::ClaimWindow::Build.call(claim_window: @claim_window, claim_window_params:)
    @claim_window.save!

    redirect_to claims_support_claim_window_path(@claim_window), flash: { success: "Claim window updated" }
  end

  def remove; end

  def destroy
    @claim_window.discard!

    redirect_to claims_support_claim_windows_path, flash: { success: "Claim window removed" }
  end

  private

  def claim_window_params
    params.require(:claims_claim_window).permit(:starts_on, :ends_on)
  end

  def set_claim_window
    @claim_window = Claims::ClaimWindow.find(params.require(:id))
  end

  def authorize_claim_window
    authorize @claim_window || Claims::ClaimWindow
  end
end
