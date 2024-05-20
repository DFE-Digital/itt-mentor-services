# == Schema Information
#
# Table name: subjects
#
#  id                :uuid             not null, primary key
#  code              :string
#  name              :string           not null
#  subject_area      :enum
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  parent_subject_id :uuid
#
# Indexes
#
#  index_subjects_on_parent_subject_id  (parent_subject_id)
#
# Foreign Keys
#
#  fk_rails_...  (parent_subject_id => subjects.id)
#
FactoryBot.define do
  factory :subject do
    subject_area { %i[primary secondary].sample }
    name { Faker::Educator.subject }
    code { Faker::Alphanumeric.alpha(number: 2) }

    trait :primary do
      subject_area { :primary }
    end

    trait :secondary do
      subject_area { :secondary }
    end
  end
end
