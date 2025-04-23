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

RSpec.describe Claims::School do
  context "with associations" do
    it { is_expected.to have_many(:claims) }
    it { is_expected.to have_many(:mentor_memberships) }
    it { is_expected.to have_many(:mentors).through(:mentor_memberships) }
    it { is_expected.to belong_to(:claims_grant_conditions_accepted_by).class_name("User").optional }
    it { is_expected.to have_many(:eligibilities).dependent(:destroy) }
    it { is_expected.to have_many(:eligible_claim_windows).through(:eligibilities) }

    describe "#users" do
      it { is_expected.to have_many(:users).through(:user_memberships) }

      it "returns only Claims::User records" do
        claims_school = create(:claims_school)
        claims_user = create(:claims_user)

        claims_school.users << claims_user
        claims_school.users << create(:placements_user)

        expect(claims_school.users).to contain_exactly(claims_user)
        expect(claims_school.users).to all(be_a(Claims::User))
      end
    end
  end

  describe "delegations" do
    it { is_expected.to delegate_method(:funding_available_per_hour).to(:region).with_prefix(true) }
    it { is_expected.to delegate_method(:name).to(:region).with_prefix(true) }
  end

  describe "#grant_conditions_accepted?" do
    it "returns true if the grant conditions have been accepted" do
      claims_user = create(:claims_user)
      claims_school = create(:claims_school, claims_grant_conditions_accepted_at: Time.zone.now, claims_grant_conditions_accepted_by_id: claims_user.id)

      expect(claims_school.grant_conditions_accepted?).to be(true)
    end

    it "returns false if the grant conditions have NOT been accepted" do
      create(:claims_user)
      claims_school = create(:claims_school, claims_grant_conditions_accepted_at: nil, claims_grant_conditions_accepted_by_id: nil)

      expect(claims_school.grant_conditions_accepted?).to be(false)
    end
  end

  describe "default scope" do
    let!(:school_with_claims) { create(:school, :claims) }
    let!(:school_without_claims) { create(:school) }

    it "is scoped to schools using the claims service" do
      school = described_class.find(school_with_claims.id)
      expect(described_class.all).to contain_exactly(school)
      expect(described_class.all).not_to include(school_without_claims)
    end
  end

  describe "#eligible_for_claim_window?" do
    let(:current_claim_window) { create(:claim_window, :current) }
    let(:historic_claim_window) { create(:claim_window, :historic) }
    let(:school) { create(:claims_school) }

    before { create(:eligibility, school:, claim_window: current_claim_window) }

    it "returns true when it is assciated with a claim window" do
      expect(
        school.eligible_for_claim_window?(current_claim_window),
      ).to be(true)

      expect(
        school.eligible_for_claim_window?(historic_claim_window),
      ).to be(false)
    end
  end
end
