# == Schema Information
#
# Table name: courses
#
#  id            :uuid             not null, primary key
#  code          :string
#  name          :string
#  subject_codes :string
#  uuid          :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  provider_id   :string
#
FactoryBot.define do
  factory :course do
    code { "MyString" }
    subject_codes { "MyString" }
  end
end
