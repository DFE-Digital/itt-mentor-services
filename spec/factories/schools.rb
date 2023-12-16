# == Schema Information
#
# Table name: schools
#
#  id         :uuid             not null, primary key
#  claims     :boolean          default(FALSE)
#  placements :boolean          default(FALSE)
#  urn        :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_schools_on_claims      (claims)
#  index_schools_on_placements  (placements)
#  index_schools_on_urn         (urn) UNIQUE
#
FactoryBot.define do
  factory :school do
    sequence(:urn) { _1 }

    trait :claims do
      claims { true }
    end

    trait :placements do
      placements { true }
    end
  end
end
