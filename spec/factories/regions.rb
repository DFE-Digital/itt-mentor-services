# == Schema Information
#
# Table name: regions
#
#  id                                         :uuid             not null, primary key
#  claims_funding_available_per_hour_currency :string           default("GBP"), not null
#  claims_funding_available_per_hour_pence    :integer          default(0), not null
#  name                                       :string           not null
#  created_at                                 :datetime         not null
#  updated_at                                 :datetime         not null
#
# Indexes
#
#  index_regions_on_name  (name) UNIQUE
#
FactoryBot.define do
  factory :region do
    names = ["Inner London", "Outer London", "Fringe", "Rest of England"].cycle

    name { names.next }

    claims_funding_available_per_hour do
      {
        "Inner London" => Money.from_amount(53.60, "GBP"),
        "Outer London" => Money.from_amount(48.25, "GBP"),
        "Fringe" => Money.from_amount(45.10, "GBP"),
        "Rest of England" => Money.from_amount(43.80, "GBP"),
      }[name]
    end
  end
end
