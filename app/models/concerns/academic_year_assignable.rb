module AcademicYearAssignable
  extend ActiveSupport::Concern

  included do
    before_validation :assign_default_academic_year, on: :create

    belongs_to :selected_academic_year, class_name: "Placements::AcademicYear"
  end

  def assign_default_academic_year
    return if selected_academic_year.present?

    self.selected_academic_year = Placements::AcademicYear.current.next
  end
end
