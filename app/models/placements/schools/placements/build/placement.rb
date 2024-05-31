# == Schema Information
#
# Table name: placements
#
#  id          :uuid             not null, primary key
#  year_group  :enum
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  provider_id :uuid
#  school_id   :uuid
#  subject_id  :uuid
#
# Indexes
#
#  index_placements_on_provider_id  (provider_id)
#  index_placements_on_school_id    (school_id)
#  index_placements_on_subject_id   (subject_id)
#
# Foreign Keys
#
#  fk_rails_...  (provider_id => providers.id)
#  fk_rails_...  (school_id => schools.id)
#  fk_rails_...  (subject_id => subjects.id)
#
class Placements::Schools::Placements::Build::Placement < Placement
  validates :school, presence: true

  attr_accessor :phase, :mentor_ids, :additional_subject_ids

  def valid_phase?
    return true if [Placements::School::PRIMARY_PHASE, Placements::School::SECONDARY_PHASE].include?(phase)

    errors.add(:phase, :invalid)
    false
  end

  def valid_subject?
    return true if subject.present? && subject.subject_area.downcase == phase.downcase

    errors.add(:subject, :invalid)
    false
  end

  def valid_mentor_ids?
    return true if mentor_ids.present? && mentor_ids.include?("not_known")

    if mentor_ids.present? && mentor_ids.all? { |id| Placements::Mentor.exists?(id:) && school.mentors.exists?(id:) }
      true
    else
      errors.add(:mentor_ids, :invalid)
      false
    end
  end

  def valid_additional_subjects?
    converted_subject_ids = additional_subject_ids.is_a?(Array) ? additional_subject_ids : [additional_subject_ids]
    if additional_subject_ids.present? && converted_subject_ids.all? { |id| Subject.exists?(id:) }
      true
    else
      errors.add(:additional_subject_ids, :invalid)
      false
    end
  end

  def valid_year_group?
    return true if school.phase != "Primary" || year_group.present?

    errors.add(:year_group, :invalid)
    false
  end

  def all_valid?
    valid_phase? && valid_subject? && valid_mentor_ids? && valid_additional_subjects?
  end

  def build_additional_subjects(additional_subject_ids = nil)
    if additional_subject_ids.present?
      additional_subjects << Subject.where(id: additional_subject_ids)
    else
      additional_subjects.build
    end
  end

  def build_mentors(mentor_ids = nil)
    if mentor_ids.present?
      mentors << Placements::Mentor.where(id: mentor_ids.compact_blank)
    else
      mentors.build
    end
  end

  def build_phase(phase)
    phase.presence ||
      (school.primary_or_secondary_only? ? school.phase : "Primary")
  end
end
