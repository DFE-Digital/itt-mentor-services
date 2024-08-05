class Claims::PagesController < Claims::ApplicationController
  skip_before_action :authenticate_user!

  before_action :skip_authorization

  before_action :redirect_to_after_sign_in_path, only: :start, if: :user_signed_in?

  helper_method :claim_window, :academic_year, :service_updates

  def start; end

  private

  def claim_window
    @claim_window ||= Claims::ClaimWindow.current || Claims::ClaimWindow.previous
  end

  def academic_year
    @academic_year ||= claim_window.academic_year
  end

  def service_updates
    MarkdownDocument.from_directory(Rails.root.join("app/views/claims/service_updates/content"))
      .select { !_1["date"].future? && _1["start_page"] }
      .sort_by { _1["date"] }
      .reverse
  end
end
