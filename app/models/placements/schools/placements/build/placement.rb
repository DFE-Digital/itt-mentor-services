# == Schema Information
#
# Table name: placements
#
#  id          :uuid             not null, primary key
#  status      :enum             default("draft")
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  provider_id :uuid
#  school_id   :uuid
#
# Indexes
#
#  index_placements_on_provider_id  (provider_id)
#  index_placements_on_school_id    (school_id)
#
# Foreign Keys
#
#  fk_rails_...  (provider_id => providers.id)
#  fk_rails_...  (school_id => schools.id)
#
class Placements::Schools::Placements::Build::Placement < Placement
  has_many :placement_mentor_joins, dependent: :destroy
  has_many :mentors, through: :placement_mentor_joins, class_name: "Placements::Mentor"

  has_many :placement_subject_joins, dependent: :destroy
  has_many :subjects, through: :placement_subject_joins

  belongs_to :school, class_name: "Placements::School"
  belongs_to :provider, optional: true

  validates :school, :status, presence: true

  attr_accessor :phase, :mentor_ids, :subject_ids

  def valid_phase?
    return true if [Placements::School::PRIMARY_PHASE, Placements::School::SECONDARY_PHASE].include?(phase)

    errors.add(:phase, :invalid)
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

  def valid_subjects?
    converted_subject_ids = subject_ids.is_a?(Array) ? subject_ids : [subject_ids]
    if subject_ids.present? && converted_subject_ids.all? { |id| Subject.exists?(id:) && Subject.find(id).subject_area.downcase == phase.downcase }
      true
    else
      errors.add(:subject_ids, :invalid)
      false
    end
  end

  def all_valid?
    valid_phase? && valid_mentor_ids? && valid_subjects?
  end

  def build_subjects(subject_ids = nil)
    if subject_ids.present?
      subjects << Subject.where(id: subject_ids)
    else
      subjects.build
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
