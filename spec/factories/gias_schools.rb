# == Schema Information
#
# Table name: gias_schools
#
#  id                           :uuid             not null, primary key
#  address1                     :string
#  address2                     :string
#  address3                     :string
#  admissions_policy            :string
#  email_address                :string
#  gender                       :string
#  group                        :string
#  last_inspection_date         :date
#  maximum_age                  :integer
#  minimum_age                  :integer
#  name                         :string           not null
#  percentage_free_school_meals :integer
#  phase                        :string
#  postcode                     :string
#  rating                       :string
#  religious_character          :string
#  school_capacity              :integer
#  send_provision               :string
#  special_classes              :string
#  telephone                    :string
#  total_boys                   :integer
#  total_girls                  :integer
#  total_pupils                 :integer
#  town                         :string
#  training_with_disabilities   :string
#  type_of_establishment        :string
#  ukprn                        :string
#  urban_or_rural               :string
#  urn                          :string           not null
#  website                      :string
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
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
