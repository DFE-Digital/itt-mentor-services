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
FactoryBot.define do
  factory :hosting_interest, class: Placements::HostingInterest do
    academic_year { Placements::AcademicYear.current }

    association :school, factory: :placements_school

    appetite { "actively_looking" }

    trait :for_next_year do
      academic_year { Placements::AcademicYear.current.next }
    end
  end
end
