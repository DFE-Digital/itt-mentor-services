# == Schema Information
#
# Table name: samplings
#
#  id         :uuid             not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
FactoryBot.define do
  factory :claims_sampling, class: "Claims::Sampling" do
    provider_samplings { build_list(:provider_sampling, 7, sampling: nil) }
  end
end
