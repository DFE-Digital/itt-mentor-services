# == Schema Information
#
# Table name: schools
#
#  id                                     :uuid             not null, primary key
#  address1                               :string
#  address2                               :string
#  address3                               :string
#  admissions_policy                      :string
#  approximate_placement_details          :jsonb
#  claims_grant_conditions_accepted_at    :datetime
#  claims_service                         :boolean          default(FALSE)
#  district_admin_code                    :string
#  district_admin_name                    :string
#  email_address                          :string
#  expression_of_interest_completed       :boolean          default(FALSE)
#  gender                                 :string
#  group                                  :string
#  last_inspection_date                   :date
#  latitude                               :float
#  local_authority_code                   :string
#  local_authority_name                   :string
#  longitude                              :float
#  maximum_age                            :integer
#  minimum_age                            :integer
#  name                                   :string
#  percentage_free_school_meals           :integer
#  phase                                  :string
#  placements_service                     :boolean          default(FALSE)
#  postcode                               :string
#  previously_offered_placements          :boolean          default(FALSE)
#  rating                                 :string
#  religious_character                    :string
#  school_capacity                        :integer
#  send_provision                         :string
#  special_classes                        :string
#  telephone                              :string
#  total_boys                             :integer
#  total_girls                            :integer
#  total_pupils                           :integer
#  town                                   :string
#  type_of_establishment                  :string
#  ukprn                                  :string
#  urban_or_rural                         :string
#  urn                                    :string
#  vendor_number                          :string
#  website                                :string
#  created_at                             :datetime         not null
#  updated_at                             :datetime         not null
#  claims_grant_conditions_accepted_by_id :uuid
#  region_id                              :uuid
#  trust_id                               :uuid
#
# Indexes
#
#  index_schools_on_claims_grant_conditions_accepted_by_id  (claims_grant_conditions_accepted_by_id)
#  index_schools_on_claims_service                          (claims_service)
#  index_schools_on_latitude                                (latitude)
#  index_schools_on_longitude                               (longitude)
#  index_schools_on_name_trigram                            (name) USING gin
#  index_schools_on_placements_service                      (placements_service)
#  index_schools_on_postcode_trigram                        (postcode) USING gin
#  index_schools_on_region_id                               (region_id)
#  index_schools_on_trust_id                                (trust_id)
#  index_schools_on_urn                                     (urn) UNIQUE
#  index_schools_on_urn_trigram                             (urn) USING gin
#
# Foreign Keys
#
#  fk_rails_...  (claims_grant_conditions_accepted_by_id => users.id)
#  fk_rails_...  (region_id => regions.id)
#  fk_rails_...  (trust_id => trusts.id)
#
require "rails_helper"

RSpec.describe School, type: :model do
  context "with associations" do
    it { is_expected.to belong_to(:region) }
    it { is_expected.to belong_to(:trust).optional }

    it { is_expected.to have_many(:user_memberships) }
    it { is_expected.to have_many(:mentor_memberships) }
    it { is_expected.to have_many(:mentors).through(:mentor_memberships) }
    it { is_expected.to have_many(:users).through(:user_memberships) }
  end

  context "with scopes" do
    describe "#placements_service" do
      it "only returns placements schools" do
        create(:school, :claims)
        create(:school)
        placements_school = create(:school, :placements)

        expect(described_class.placements_service).to contain_exactly(placements_school)
      end
    end

    describe "#claims_service" do
      it "only returns claims schools" do
        create(:school, :placements)
        create(:school)
        claims_school = create(:school, :claims)

        expect(described_class.claims_service).to contain_exactly(claims_school)
      end
    end

    describe "#order_by_name" do
      it "returns the schools ordered by name" do
        school_1 = create(:school, name: "Brixton School")
        school_2 = create(:school, name: "Abbey School")
        school_3 = create(:school, name: "Brighton School")

        expect(described_class.order_by_name).to eq([school_2, school_3, school_1])
      end
    end
  end

  context "with validations" do
    subject { create(:school) }

    it { is_expected.to validate_uniqueness_of(:urn).case_insensitive }
    it { is_expected.to validate_uniqueness_of(:vendor_number).case_insensitive }

    it { is_expected.to validate_presence_of(:name) }
  end

  describe "#organisation_type" do
    subject { school.organisation_type }

    let(:school) { create(:school) }

    it { is_expected.to eq("school") }
  end

  describe "#primary_or_secondary_only?" do
    subject { school.primary_or_secondary_only? }

    context "when given a school with phase Primary" do
      let(:school) { create(:school, phase: "Primary") }

      it { is_expected.to be(true) }
    end

    context "when given a school with phase Secondary" do
      let(:school) { create(:school, phase: "Secondary") }

      it { is_expected.to be(true) }
    end

    context "when given a school with phase not Primary or Secondary" do
      let(:school) { create(:school, phase: "All-through") }

      it { is_expected.to be(false) }
    end
  end

  describe "geocoder" do
    describe "#near" do
      let!(:uxbridge_school) do
        create(:school, name: "Uxbridge School", latitude: 51.5449509, longitude: -0.4816672)
      end
      let!(:brixton_school) do
        create(:school, name: "Brixton School", latitude: 51.4626818, longitude: -0.1147325)
      end
      let(:york_school) do
        create(:school, name: "York School", latitude: 53.9590555, longitude: -1.0815361)
      end
      let(:london_coordinates) { [51.4893335, -0.14405508452768728] }

      before do
        york_school
      end

      it "returns the schools near the search for area" do
        expect(
          described_class.near(london_coordinates, 20),
        ).to contain_exactly(uxbridge_school, brixton_school)
      end
    end
  end

  describe "#address" do
    context "when all address attributes are present" do
      let!(:uxbridge_school) do
        create(:school,
               name: "Uxbridge School",
               address1: "Uxbridge School",
               address2: "Uxbridge",
               address3: "Greater London",
               town: "London",
               postcode: "UB8 1SB")
      end

      it "returns the full address of the school" do
        expect(uxbridge_school.address).to eq(
          "Uxbridge School, Uxbridge, Greater London, London, UB8 1SB, United Kingdom",
        )
      end
    end

    context "when not all address attributes are present" do
      let!(:uxbridge_school) do
        create(:school,
               name: "Uxbridge School",
               address1: "Uxbridge School",
               town: "London",
               postcode: "UB8 1SB")
      end

      it "concatenate the present address attributes" do
        expect(uxbridge_school.address).to eq(
          "Uxbridge School, London, UB8 1SB, United Kingdom",
        )
      end
    end
  end

  describe "#primary?" do
    it "returns true for primary schools" do
      school = described_class.new(phase: "Primary")
      expect(school.primary?).to be(true)
    end

    it "returns false for secondary schools" do
      school = described_class.new(phase: "Secondary")
      expect(school.primary?).to be(false)
    end
  end

  describe "#email_addresses" do
    subject(:email_addresses) { school.email_addresses }

    context "when the school does not have an email address" do
      let(:school) { create(:school) }

      it "returns an empty array" do
        expect(email_addresses).to eq([])
      end
    end

    context "when the school does have an email address" do
      let(:school) { create(:school, email_address: "school@example.com") }

      it "returns an array containing the school's email address" do
        expect(email_addresses).to contain_exactly("school@example.com")
      end
    end
  end
end
