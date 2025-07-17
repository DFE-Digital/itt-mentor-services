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

    transient do
      claims_for_link { [] }
    end

    after(:build) do |sampling, eval|
      eval.claims_for_link.each do |claim|
        provider_sampling = build(:provider_sampling, sampling:)
        provider_sampling.provider_sampling_claims.build(claim:)
        sampling.provider_samplings << provider_sampling
      end
    end
  end
end
