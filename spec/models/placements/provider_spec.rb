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

RSpec.describe Placements::Provider do
  describe "associations" do
    it { is_expected.to have_many(:placements) }

    describe "#users" do
      it { is_expected.to have_many(:users).through(:user_memberships) }

      it "returns only Placements::User records" do
        placements_provider = create(:placements_provider)
        placements_user = create(:placements_user)

        placements_provider.users << create(:claims_user)
        placements_provider.users << placements_user

        expect(placements_provider.users).to contain_exactly(placements_user)
        expect(placements_provider.users).to all(be_a(Placements::User))
      end
    end

    describe "#partnerships" do
      it { is_expected.to have_many(:partnerships) }
    end

    describe "#partner_schools" do
      it { is_expected.to have_many(:partner_schools).through(:partnerships) }

      it "returns School records" do
        placements_provider = create(:placements_provider)
        placements_school = create(:school, :placements)
        claims_school = create(:school, :claims)
        school = create(:school)

        placements_provider.partner_schools << claims_school
        placements_provider.partner_schools << placements_school
        placements_provider.partner_schools << school

        expect(placements_provider.partner_schools).to contain_exactly(placements_school, claims_school, school)
        expect(placements_provider.partner_schools).to all(be_a(School))
      end
    end
  end

  describe "default scope" do
    let!(:provider_with_placements) { create(:provider, :placements) }
    let!(:provider_without_placements) { create(:provider) }

    it "is scoped to providers using the placement service" do
      provider = described_class.find(provider_with_placements.id)
      expect(described_class.all).to contain_exactly(provider)
      expect(described_class.all).not_to include(provider_without_placements)
    end
  end
end
