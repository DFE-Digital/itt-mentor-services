class Claims::Support::ClaimsRemindersController < Claims::Support::ApplicationController
  before_action :skip_authorization
  before_action :set_claim_window
  before_action :set_schools, only: %i[schools_not_submitted_claims send_schools_not_submitted_claims]

  def schools_not_submitted_claims; end

  def send_schools_not_submitted_claims
    @schools.flat_map(&:users).each do |user|
      Claims::UserMailer.claims_have_not_been_submitted(user).deliver_later
    end

    redirect_to schools_not_submitted_claims_claims_support_claims_reminders_path, flash: {
      heading: t(".success"),
      body: t(".success_body"),
    }
  end

  private

  def set_claim_window
    @claim_window = Claims::ClaimWindow.current.decorate
  end

  def set_schools
    @schools = Claims::School.includes(:users, :eligible_claim_windows)
                             .where(eligible_claim_windows: { id: @claim_window.id })
                             .where.missing(:claims)
  end
end
