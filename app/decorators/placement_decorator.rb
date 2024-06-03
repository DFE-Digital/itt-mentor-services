class PlacementDecorator < Draper::Decorator
  delegate_all
  decorates_association :school

  delegate :name, to: :subject, prefix: true, allow_nil: true

  def mentor_names
    if mentors.any?
      mentors.map(&:full_name).sort.to_sentence
    else
      I18n.t("placements.schools.placements.not_yet_known")
    end
  end

  def title
    placement_title = if additional_subjects.present?
                        additional_subject_names.to_sentence
                      else
                        subject_name
                      end
    return placement_title if year_group.blank?

    "#{placement_title} (#{I18n.t("placements.schools.placements.year_groups.#{year_group}")})"
  end

  def school_level
    subject.subject_area.titleize
  end

  def provider_name
    provider&.name || I18n.t("placements.schools.placements.not_yet_known")
  end

  def additional_subject_names
    additional_subjects.map(&:name).sort
  end
end
