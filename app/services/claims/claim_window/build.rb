class Claims::ClaimWindow::Build
  include ServicePattern

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

    year = claim_window.starts_on.month > 1 ? claim_window.starts_on.year - 1 : claim_window.starts_on.year - 2

    AcademicYear.create_with(
      starts_on: Date.new(year, 9, 1),
      ends_on: Date.new(year + 1, 8, 31),
    ).find_or_create_by!(name: "#{year} to #{year + 1}")
  end
end
