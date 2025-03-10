# == Schema Information
#
# Table name: hosting_interests
#
#  id                       :uuid             not null, primary key
#  appetite                 :enum
#  other_reason_not_hosting :text
#  reasons_not_hosting      :jsonb
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  academic_year_id         :uuid             not null
#  school_id                :uuid             not null
#
# Indexes
#
#  index_hosting_interests_on_academic_year_id                (academic_year_id)
#  index_hosting_interests_on_school_id                       (school_id)
#  index_hosting_interests_on_school_id_and_academic_year_id  (school_id,academic_year_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (academic_year_id => academic_years.id)
#  fk_rails_...  (school_id => schools.id)
#
class Placements::HostingInterest < ApplicationRecord
  belongs_to :academic_year, class_name: "Placements::AcademicYear"
  belongs_to :school, class_name: "Placements::School"

  validates :academic_year_id, uniqueness: { scope: :school_id }

  enum :appetite,
       {
         actively_looking: "actively_looking",
         interested: "interested",
         not_open: "not_open",
         already_organised: "already_organised",
       },
       validate: true

  scope :for_academic_year, ->(academic_year) { where(academic_year:) }
end
