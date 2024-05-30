class PlacementDecorator < Draper::Decorator
  delegate_all
  decorates_association :school

  def mentor_names
    if mentors.any?
      mentors.map(&:full_name).sort.to_sentence
    else
      I18n.t("placements.schools.placements.not_yet_known")
    end
  end

  def subject_name
    if additional_subjects.exists?
      additional_subject_names.to_sentence
    elsif subject.present?
      subject.name
    else
      I18n.t("placements.schools.placements.not_yet_known")
    end
  end

  def school_level
    subject.subject_area.titleize
  end

  def provider_name
    provider&.name || I18n.t("placements.schools.placements.not_yet_known")
  end
end
