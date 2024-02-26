class PlacementDecorator < Draper::Decorator
  delegate_all

  def mentor_names
    if mentors.any?
      mentors.map(&:full_name).sort.to_sentence
    else
      I18n.t("placements.schools.placements.not_entered")
    end
  end

  def subject_names
    subjects.pluck(:name).sort.to_sentence
  end

  def school_level
    subjects.pick(:subject_area).titleize
  end

  def window
    I18n.t(
      "placements.schools.placements.window_date",
      start_month: I18n.l(start_date, format: :month),
      end_month: I18n.l(end_date, format: :month),
    )
  end

  def formatted_start_date
    I18n.l(start_date, format: :long)
  end
end
