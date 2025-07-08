class AcademicYearDecorator < Draper::Decorator
  delegate_all

  def display_name
    case academic_year
    when Placements::AcademicYear.current
      I18n.t("placements.academic_year.current_academic_year", academic_year: academic_year.name)
    when Placements::AcademicYear.current.next
      I18n.t("placements.academic_year.next_academic_year", academic_year: academic_year.name)
    else
      I18n.t("placements.academic_year.previous_academic_year", academic_year: academic_year.name)
    end
  end

  def card_name
    case academic_year
    when AcademicYear.for_date(Date.current)
      "#{academic_year.name} #{I18n.t("placements.academic_year.current")}"
    else
      academic_year.name
    end
  end
end
