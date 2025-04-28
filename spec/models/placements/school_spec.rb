# == Schema Information
#
# Table name: schools
#
#  id                                     :uuid             not null, primary key
#  address1                               :string
#  address2                               :string
#  address3                               :string
#  admissions_policy                      :string
#  claims_grant_conditions_accepted_at    :datetime
#  claims_service                         :boolean          default(FALSE)
#  district_admin_code                    :string
#  district_admin_name                    :string
#  email_address                          :string
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

RSpec.describe Placements::School do
  context "with associations" do
    it { is_expected.to have_one(:school_contact).dependent(:destroy) }

    it { is_expected.to have_many(:mentor_memberships) }
    it { is_expected.to have_many(:mentors).through(:mentor_memberships) }
    it { is_expected.to have_many(:placements) }
    it { is_expected.to have_many(:academic_years).through(:placements) }

    describe "#users" do
      it { is_expected.to have_many(:users).through(:user_memberships) }

      it "returns only Placements::User records" do
        placements_school = create(:placements_school)
        placements_user = create(:placements_user)

        placements_school.users << create(:claims_user)
        placements_school.users << placements_user

        expect(placements_school.users).to contain_exactly(placements_user)
        expect(placements_school.users).to all(be_a(Placements::User))
      end
    end

    describe "#partnerships" do
      it { is_expected.to have_many(:partnerships) }
    end

    describe "#partner_providers" do
      it { is_expected.to have_many(:partner_providers).through(:partnerships) }

      it "returns only Placements::Provider records" do
        placements_school = create(:placements_school)
        placements_provider = create(:provider, :placements)
        provider = create(:provider)

        placements_school.partner_providers << placements_provider
        placements_school.partner_providers << provider

        expect(placements_school.partner_providers).to contain_exactly(placements_provider, provider)
        expect(placements_school.partner_providers).to all(be_a(Provider))
      end
    end
  end

  describe "default scope" do
    let!(:school_with_placements) { create(:school, :placements) }
    let!(:school_without_placements) { create(:school) }

    it "is scoped to schools using the placement service" do
      school = described_class.find(school_with_placements.id)
      expect(described_class.all).to contain_exactly(school)
      expect(described_class.all).not_to include(school_without_placements)
    end
  end

  describe "delegations" do
    it { is_expected.to delegate_method(:email_address).to(:school_contact).with_prefix(true).allow_nil }
    it { is_expected.to delegate_method(:full_name).to(:school_contact).with_prefix(true).allow_nil }
  end

  describe "#current_hosting_interest" do
    let(:academic_year) { Placements::AcademicYear.current }
    let(:school) { create(:placements_school, hosting_interests:) }

    context "when there is a current hosting interest" do
      let(:hosting_interests) { [build(:hosting_interest, academic_year:)] }

      it "returns the current hosting interest for the school" do
        expect(school.current_hosting_interest(academic_year:)).to eq(hosting_interests.first)
      end
    end

    context "when there is no current hosting interest" do
      let(:hosting_interests) { [] }

      it "returns nil" do
        expect(school.current_hosting_interest(academic_year:)).to be_nil
      end
    end

    context "when there are multiple hosting interests" do
      let(:current_hosting_interest) { build(:hosting_interest) }
      let(:previous_hosting_interest) { build(:hosting_interest, academic_year: academic_year.previous) }
      let(:hosting_interests) { [current_hosting_interest, previous_hosting_interest] }

      it "returns the current hosting interest for the school" do
        expect(school.current_hosting_interest(academic_year:)).to eq(current_hosting_interest)
      end
    end
  end

  describe "#available_placements" do
    let(:academic_year) { Placements::AcademicYear.current }
    let!(:school) { create(:placements_school, placements: [available_placement, unavailable_placement]) }
    let(:available_placement) { build(:placement) }
    let(:unavailable_placement) { build(:placement, provider: create(:provider)) }

    it "returns the available placements for the school" do
      expect(school.available_placements(academic_year:)).to contain_exactly(available_placement)
    end
  end

  describe "#unavailable_placements" do
    let(:academic_year) { Placements::AcademicYear.current }
    let!(:school) { create(:placements_school, placements: [available_placement, unavailable_placement]) }
    let(:available_placement) { build(:placement) }
    let(:unavailable_placement) { build(:placement, provider: create(:provider)) }

    it "returns the unavailable placements for the school" do
      expect(school.unavailable_placements(academic_year:)).to contain_exactly(unavailable_placement)
    end
  end
end
