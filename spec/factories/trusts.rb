# == Schema Information
#
# Table name: trusts
#
#  id         :uuid             not null, primary key
#  name       :string           not null
#  uid        :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_trusts_on_uid  (uid) UNIQUE
#
FactoryBot.define do
  factory :trust do
    uid { _1 }
    name { "Department for Education Trust" }
  end
end
