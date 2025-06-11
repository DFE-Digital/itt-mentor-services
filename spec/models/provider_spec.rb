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

RSpec.describe Provider, type: :model do
  context "with associations" do
    it { is_expected.to have_many(:user_memberships) }
    it { is_expected.to have_many(:users).through(:user_memberships) }
    it { is_expected.to have_many(:provider_email_addresses) }
  end

  describe "enums" do
    subject(:test_provider) { build(:provider) }

    it "defines the expected values" do
      expect(test_provider).to define_enum_for(:provider_type)
       .with_values(scitt: "scitt", lead_school: "lead_school", university: "university")
       .backed_by_column_of_type(:enum)
    end
  end

  context "with validations" do
    subject(:test_provider) { build(:provider) }

    it { is_expected.to validate_presence_of(:code) }
    it { is_expected.to validate_presence_of(:name) }

    it do
      expect(test_provider).to validate_uniqueness_of(
        :code,
      ).case_insensitive
    end

    it { is_expected.to allow_values(:scitt, :lead_school, :university).for(:provider_type) }
  end

  context "with scopes" do
    describe "#accredited" do
      let!(:accredited_provider) { create(:provider, accredited: true) }
      let!(:non_accredited_provider) { create(:provider) }

      it "only returns the providers which have been onboarded (placements: true)" do
        expect(described_class.accredited).to contain_exactly(accredited_provider)
        expect(described_class.accredited).not_to include(non_accredited_provider)
      end
    end

    describe "#placements_service" do
      it "only returns placements providers" do
        create(:provider)
        placements_provider = create(:provider, :placements)

        expect(described_class.placements_service).to contain_exactly(placements_provider)
      end
    end

    describe "#order_by_name" do
      it "returns the providers ordered by name" do
        provider_1 = create(:provider, name: "Brixton Provider")
        provider_2 = create(:provider, name: "Abbey Provider")
        provider_3 = create(:provider, name: "Brighton Provider")

        expect(described_class.order_by_name).to eq([provider_2, provider_3, provider_1])
      end
    end

    describe "#excluding_niot_providers" do
      let!(:niot_headquarters) { create(:provider, code: "2N2") }
      let!(:other_provider) { create(:provider, code: "3L3") }
      let!(:niot_site_1) { create(:provider, code: "1YF") }
      let!(:niot_site_2) { create(:provider, code: "21J") }
      let!(:niot_site_3) { create(:provider, code: "1GV") }
      let!(:niot_site_4) { create(:provider, code: "2HE") }
      let!(:niot_site_5) { create(:provider, code: "24P") }
      let!(:niot_site_6) { create(:provider, code: "1MN") }
      let!(:niot_site_7) { create(:provider, code: "1TZ") }
      let!(:niot_site_8) { create(:provider, code: "5J5") }
      let!(:niot_site_9) { create(:provider, code: "7K9") }
      let!(:niot_site_10) { create(:provider, code: "L06") }
      let!(:niot_site_11) { create(:provider, code: "2P4") }
      let!(:niot_site_12) { create(:provider, code: "21P") }
      let!(:niot_site_13) { create(:provider, code: "1FE") }
      let!(:niot_site_14) { create(:provider, code: "3P4") }
      let!(:niot_site_15) { create(:provider, code: "3L4") }
      let!(:niot_site_16) { create(:provider, code: "2H7") }
      let!(:niot_site_17) { create(:provider, code: "2A6") }
      let!(:niot_site_18) { create(:provider, code: "4W2") }
      let!(:niot_site_19) { create(:provider, code: "4L1") }
      let!(:niot_site_20) { create(:provider, code: "4L3") }
      let!(:niot_site_21) { create(:provider, code: "4C2") }
      let!(:niot_site_22) { create(:provider, code: "5A6") }
      let!(:niot_site_23) { create(:provider, code: "2U6") }

      it "returns all providers except those with the NIOT code" do
        expect(described_class.excluding_niot_providers).to contain_exactly(niot_headquarters, other_provider)
        expect(described_class.excluding_niot_providers).not_to include(
          niot_site_1, niot_site_2, niot_site_3, niot_site_4,
          niot_site_5, niot_site_6, niot_site_7, niot_site_8, niot_site_9,
          niot_site_10, niot_site_11, niot_site_12, niot_site_13,
          niot_site_14, niot_site_15, niot_site_16, niot_site_17,
          niot_site_18, niot_site_19, niot_site_20, niot_site_21,
          niot_site_22, niot_site_23
        )
      end
    end
  end

  describe ".order_by_ids" do
    let!(:provider_1) { create(:provider) }
    let!(:provider_2) { create(:provider) }
    let!(:provider_3) { create(:provider) }

    it "returns the providers ordered by a given list of provider ids" do
      expect(
        described_class.order_by_ids(
          [provider_2.id, provider_3.id, provider_1.id],
        ),
      ).to eq(
        [provider_2, provider_3, provider_1],
      )

      expect(
        described_class.order_by_ids(
          [provider_3.id, provider_2.id, provider_1.id],
        ),
      ).to eq(
        [provider_3, provider_2, provider_1],
      )
    end
  end

  describe "geocoder" do
    describe "#near" do
      let!(:uxbridge_provider) do
        create(:provider, name: "Uxbridge Provider", latitude: 51.5449509, longitude: -0.4816672)
      end
      let!(:brixton_provider) do
        create(:provider, name: "Brixton Provider", latitude: 51.4626818, longitude: -0.1147325)
      end
      let(:york_provider) do
        create(:provider, name: "York School", latitude: 53.9590555, longitude: -1.0815361)
      end
      let(:london_coordinates) { [51.4893335, -0.14405508452768728] }

      before do
        york_provider
      end

      it "returns the schools near the search for area" do
        expect(
          described_class.near(london_coordinates, 20),
        ).to contain_exactly(uxbridge_provider, brixton_provider)
      end
    end
  end

  describe "#address" do
    context "when all address attributes are present" do
      let!(:uxbridge_provider) do
        create(:provider,
               name: "Uxbridge Provider",
               address1: "Uxbridge Provider",
               address2: "Uxbridge",
               address3: "Greater London",
               city: "London",
               county: "London",
               postcode: "UB8 1SB")
      end

      it "returns the full address of the school" do
        expect(uxbridge_provider.address).to eq(
          "Uxbridge Provider, Uxbridge, Greater London, London, London, UB8 1SB, United Kingdom",
        )
      end
    end

    context "when not all address attributes are present" do
      let!(:uxbridge_provider) do
        create(:provider,
               name: "Uxbridge Provider",
               address1: "Uxbridge Provider",
               city: "London",
               postcode: "UB8 1SB")
      end

      it "concatenate the present address attributes" do
        expect(uxbridge_provider.address).to eq(
          "Uxbridge Provider, London, UB8 1SB, United Kingdom",
        )
      end
    end
  end
end
