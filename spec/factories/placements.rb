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
FactoryBot.define do
  factory :placement do
    association :school, factory: :placements_school
    association :subject, factory: :subject
  end
end
