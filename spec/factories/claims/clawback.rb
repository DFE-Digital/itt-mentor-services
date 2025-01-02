FactoryBot.define do
  factory :claims_clawback, class: "Claims::Clawback" do
    claims { build_list(:claim, 3, :submitted, status: :clawback_requested) }
  end
end
