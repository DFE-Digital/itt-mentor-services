# == Schema Information
#
# Table name: placements
#
#  id               :uuid             not null, primary key
#  school_id        :uuid
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  provider_id      :uuid
#  subject_id       :uuid
#  year_group       :enum
#  academic_year_id :uuid             not null
#  creator_type     :string
#  creator_id       :uuid
#
# Indexes
#
#  index_placements_on_academic_year_id  (academic_year_id)
#  index_placements_on_creator           (creator_type,creator_id)
#  index_placements_on_provider_id       (provider_id)
#  index_placements_on_school_id         (school_id)
#  index_placements_on_subject_id        (subject_id)
#  index_placements_on_year_group        (year_group)
#

FactoryBot.define do
  factory :placement do
    academic_year { Placements::AcademicYear.current }

    association :school, factory: :placements_school
    association :subject, factory: :subject

    trait :send do
      subject { nil }
      send_specific { true }
    end
  end
end
