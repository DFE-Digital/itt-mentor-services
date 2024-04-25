class PlacementDecorator < Draper::Decorator
  delegate_all
  decorates_association :school

  def mentor_names
    if mentors.any?
      mentors.map(&:full_name).sort.to_sentence
    else
      I18n.t("placements.schools.placements.not_known_yet")
    end
  end

  def subject_names
    if subjects.any?
      subjects.pluck(:name).sort.to_sentence
    else
      I18n.t("placements.schools.placements.not_known_yet")
    end
  end

  def school_level
    subjects.pick(:subject_area).titleize
  end

  def formatted_start_date
    I18n.l(start_date, format: :long)
  end
end
