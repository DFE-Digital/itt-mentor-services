# == Schema Information
#
# Table name: trainees
#
#  id                :uuid             not null, primary key
#  itt_course_code   :string
#  itt_course_uuid   :string
#  study_mode        :string
#  training_provider :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  candidate_id      :string
#  course_id         :uuid
#  provider_id       :uuid
#
# Indexes
#
#  index_trainees_on_course_id    (course_id)
#  index_trainees_on_provider_id  (provider_id)
#
# Foreign Keys
#
#  fk_rails_...  (course_id => courses.id)
#  fk_rails_...  (provider_id => providers.id)
#
FactoryBot.define do
  factory :trainee do
    candidate_id { "MyString" }
    itt_course_code { "MyString" }
    training_provider_code { "MyString" }
  end
end
