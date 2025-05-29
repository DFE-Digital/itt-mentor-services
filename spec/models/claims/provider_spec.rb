# == Schema Information
#
# Table name: providers
#
#  id                 :uuid             not null, primary key
#  accredited         :boolean          default(FALSE)
#  address1           :string
#  address2           :string
#  address3           :string
#  city               :string
#  code               :string           not null
#  county             :string
#  latitude           :float
#  longitude          :float
#  name               :string           default(""), not null
#  placements_service :boolean          default(FALSE)
#  postcode           :string
#  provider_type      :enum             default("scitt"), not null
#  telephone          :string
#  town               :string
#  ukprn              :string
#  urn                :string
#  website            :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
# Indexes
#
#  index_providers_on_code                (code) UNIQUE
#  index_providers_on_latitude            (latitude)
#  index_providers_on_longitude           (longitude)
#  index_providers_on_name_trigram        (name) USING gin
#  index_providers_on_placements_service  (placements_service)
#  index_providers_on_postcode_trigram    (postcode) USING gin
#  index_providers_on_provider_type       (provider_type)
#  index_providers_on_ukprn_trigram       (ukprn) USING gin
#  index_providers_on_urn_trigram         (urn) USING gin
#
require "rails_helper"

RSpec.describe Claims::Provider, type: :model do
  context "with associations" do
    it { is_expected.to have_many(:mentor_trainings) }
    it { is_expected.to have_many(:claims) }
  end

  describe "scopes" do
    describe "#private_beta_providers" do
      it "returns only the private beta providers" do
        provider1 = create(:claims_provider, :best_practice_network)
        provider2 = create(:claims_provider, :niot)
        provider3 = create(:claims_provider)

        expect(described_class.private_beta_providers).to eq([provider1, provider2])
        expect(described_class.private_beta_providers).not_to include(provider3)
      end
    end
  end
end
