class Placements::AddPlacementWizard::AcademicYearStep < Placements::BaseStep
  attribute :academic_year_id

  validates :academic_year_id, presence: true

  def academic_years_for_selection
    [current_academic_year, current_academic_year.next]
  end

  private

  def current_academic_year
    @current_academic_year ||= Placements::AcademicYear.current
  end
end
