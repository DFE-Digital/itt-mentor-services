# == Schema Information
#
# Table name: courses
#
#  id            :uuid             not null, primary key
#  code          :string
#  subject_codes :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
FactoryBot.define do
  factory :course do
    code { "MyString" }
    subject_code { "MyString" }
  end
end
