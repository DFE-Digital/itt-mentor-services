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
#  index_placements_on_year_group   (year_group)
#
# Foreign Keys
#
#  fk_rails_...  (provider_id => providers.id)
#  fk_rails_...  (school_id => schools.id)
#  fk_rails_...  (subject_id => subjects.id)
#
class Placements::Schools::Placements::Build::Placement < Placement
  validates :school, presence: true

  attr_accessor :phase, :mentor_ids

  def valid_phase?
    return true if [Placements::School::PRIMARY_PHASE, Placements::School::SECONDARY_PHASE].include?(phase)

    errors.add(:phase, :invalid)
    false
  end

  def all_valid?
    valid_phase?
  end

  def build_mentors(mentor_ids)
    return if mentor_ids.empty?

    mentors << Placements::Mentor.where(id: mentor_ids)
  end

  def build_phase(phase)
    phase.presence ||
      (school.primary_or_secondary_only? ? school.phase : "Primary")
  end
end
