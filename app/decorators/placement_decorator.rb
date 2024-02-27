class PlacementDecorator < Draper::Decorator
  delegate_all

  def mentor_names
    if mentors.any?
      mentors.map(&:full_name).sort.to_sentence
    else
      I18n.t("placements.schools.placements.not_known_yet")
    end
  end

  def subject_names
    subjects.pluck(:name).sort.to_sentence
  end

  def school_level
    subjects.pick(:subject_area).titleize
  end

  def window
    if start_date.month == 9 && end_date.month == 12
      I18n.t("placements.schools.placements.terms.autumn")
    elsif start_date.month == 1 && end_date.month == 3
      I18n.t("placements.schools.placements.terms.spring")
    elsif start_date.month == 4 && end_date.month == 7
      I18n.t("placements.schools.placements.terms.summer")
    else
      I18n.t(
        "placements.schools.placements.window_date",
        start_month: I18n.l(start_date, format: :month),
        end_month: I18n.l(end_date, format: :month),
      )
    end
  end

  def formatted_start_date
    I18n.l(start_date, format: :long)
  end
end
