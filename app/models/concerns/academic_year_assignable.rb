module AcademicYearAssignable
  extend ActiveSupport::Concern

  included do
    before_validation :assign_default_academic_year, on: :create

    belongs_to :selected_academic_year, class_name: "Placements::AcademicYear"
  end

  def assign_default_academic_year
    self.selected_academic_year = Placements::AcademicYear.current.next
  end
end
