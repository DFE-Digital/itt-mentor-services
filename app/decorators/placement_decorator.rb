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
    subjects.map(&:name).sort.to_sentence
  end

  def formatted_start_date
    I18n.l(start_date, format: :long)
  end
end
