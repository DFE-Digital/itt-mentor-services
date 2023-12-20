# == Schema Information
#
# Table name: gias_schools
#
#  id         :uuid             not null, primary key
#  address1   :string
#  address2   :string
#  address3   :string
#  name       :string           not null
#  postcode   :string
#  telephone  :string
#  town       :string
#  ukprn      :string
#  urn        :string           not null
#  website    :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_gias_schools_on_urn  (urn) UNIQUE
#
FactoryBot.define do
  factory :gias_school do
    sequence(:urn) { |n| "fake_urn#{n}" }
    name { "Hogwarts" }
    sequence(:ukprn) { |n| "fake_uprn_#{n}" }
    telephone { "0123456789" }
    website { "www.hogwarts.com" }
    address1 { "Hogwarts Castle" }
    address2 { "Scotland" }
    address3 { "United Kingdom" }
  end
end
