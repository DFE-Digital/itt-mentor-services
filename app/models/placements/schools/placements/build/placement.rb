class Placements::Schools::Placements::Build::Placement < Placement
  has_many :placement_mentor_joins, dependent: :destroy
  has_many :mentors, through: :placement_mentor_joins, class_name: "Placements::Mentor"

  has_many :placement_subject_joins, dependent: :destroy
  has_many :subjects, through: :placement_subject_joins

  belongs_to :school, class_name: "Placements::School"

  validates :school, :status, presence: true

  attr_accessor :phase, :mentor_ids, :subject_ids

  def valid_phase?
    return true if phase.present? && [Placements::School::PRIMARY_PHASE, Placements::School::SECONDARY_PHASE].include?(phase)

    errors.add(:phase, "Select a phase")
    false
  end

  def valid_mentor_ids?
    return true if mentor_ids.present? && mentor_ids.include?("not_known")

    if mentor_ids.present? && mentor_ids.all? { |id| Placements::Mentor.exists?(id:) && school.mentors.exists?(id:) }
      true
    else
      errors.add(:mentor_ids, "Select a mentor or not known")
      false
    end
  end

  def valid_subjects?
    converted_subject_ids = subject_ids.is_a?(Array) ? subject_ids : [subject_ids]
    if subject_ids.present? && converted_subject_ids.all? { |id| Subject.exists?(id:) && Subject.find(id).subject_area.downcase == phase.downcase }
      true
    else
      errors.add(:subject_ids, "Select a subject")
      false
    end
  end

  def all_valid?
    valid_phase? && valid_mentor_ids? && valid_subjects?
  end

  def build_subjects(subject_ids = nil)
    if subject_ids.instance_of?(String)
      subjects << Subject.find(subject_ids)
    elsif subject_ids.present?
      subject_ids.each { |subject_id| subjects << Subject.find(subject_id) }
    else
      subjects.build
    end
  end

  def build_mentors(mentor_ids = nil)
    if mentor_ids.present?
      mentor_ids.compact_blank.each do |mentor_id|
        mentors << Placements::Mentor.find(mentor_id)
      end
    else
      mentors.build
    end
  end
end
