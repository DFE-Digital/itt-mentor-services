class Claims::ClaimWindow::Build < ApplicationService
  def initialize(claim_window_params:, claim_window: nil)
    @claim_window = claim_window
    @claim_window_params = claim_window_params
  end

  def call
    self.claim_window ||= Claims::ClaimWindow.new
    self.claim_window.assign_attributes(claim_window_params)
    self.claim_window.academic_year = find_academic_year
    self.claim_window
  end

  private

  attr_accessor :claim_window, :claim_window_params

  def find_academic_year
    return unless claim_window.starts_on

    AcademicYear.for_date(claim_window.starts_on)
  end
end
