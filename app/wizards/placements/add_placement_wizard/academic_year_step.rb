class Placements::AddPlacementWizard::AcademicYearStep < Placements::BaseStep
  attribute :academic_year_id

  validates :academic_year_id, presence: true

  def academic_years_for_selection
    [
      create_struct_for_academic_year_selection(current_academic_year),
      create_struct_for_academic_year_selection(current_academic_year.next),
    ]
  end

  def academic_year_display_name(academic_year)
    case academic_year
    when current_academic_year
      I18n.t("placements.wizards.add_placement_wizard.academic_year_step.current_academic_year", academic_year: academic_year.name)
    when current_academic_year.next
      I18n.t("placements.wizards.add_placement_wizard.academic_year_step.next_academic_year", academic_year: academic_year.name)
    end
  end

  def academic_year
    Placements::AcademicYear.find(academic_year_id)
  end

  private

  def current_academic_year
    @current_academic_year ||= Placements::AcademicYear.current
  end

  def create_struct_for_academic_year_selection(academic_year)
    OpenStruct.new value: academic_year.id, name: academic_year_display_name(academic_year)
  end
end
