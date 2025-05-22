class PlacementDecorator < Draper::Decorator
  delegate_all
  decorates_association :school
  decorates_association :academic_year

  delegate :name, to: :subject, prefix: true, allow_nil: true

  def mentor_names
    if mentors.any?
      mentors.order_by_full_name.map(&:full_name).sort.to_sentence
    else
      I18n.t("placements.schools.placements.not_yet_known")
    end
  end

  def title
    if send_specific && key_stages.present?
      "#{I18n.t("placements.schools.placements.send")} (#{key_stages.order_by_name.pluck(:name).join(", ")})"
    elsif send_specific
      I18n.t("placements.schools.placements.send")
    else
      placement_title = if additional_subjects.present?
                          additional_subject_names
                        else
                          subject_name
                        end
      return placement_title if year_group.blank?

      "#{placement_title} (#{I18n.t("placements.schools.placements.year_groups.#{year_group}")})"
    end
  end

  def school_level
    subject.subject_area.titleize
  end

  def provider_name
    provider&.name || I18n.t("placements.schools.placements.not_yet_known")
  end

  def additional_subject_names
    reload unless new_record?
    additional_subjects.map(&:name).sort.to_sentence
  end

  def term_names
    if terms.exists?
      terms.order_by_term.pluck(:name).join(", ")
    elsif new_record? && terms.any?
      terms.map(&:name).sort.join(", ")
    else
      I18n.t("placements.schools.placements.terms.any_term")
    end
  end
end
