# == Schema Information
#
# Table name: schools
#
#  id                           :uuid             not null, primary key
#  address1                     :string
#  address2                     :string
#  address3                     :string
#  admissions_policy            :string
#  claims_service               :boolean          default(FALSE)
#  district_admin_code          :string
#  district_admin_name          :string
#  email_address                :string
#  gender                       :string
#  group                        :string
#  last_inspection_date         :date
#  local_authority_code         :string
#  local_authority_name         :string
#  maximum_age                  :integer
#  minimum_age                  :integer
#  name                         :string
#  percentage_free_school_meals :integer
#  phase                        :string
#  placements_service           :boolean          default(FALSE)
#  postcode                     :string
#  rating                       :string
#  religious_character          :string
#  school_capacity              :integer
#  send_provision               :string
#  special_classes              :string
#  telephone                    :string
#  total_boys                   :integer
#  total_girls                  :integer
#  total_pupils                 :integer
#  town                         :string
#  training_with_disabilities   :string
#  type_of_establishment        :string
#  ukprn                        :string
#  urban_or_rural               :string
#  urn                          :string           not null
#  website                      :string
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  region_id                    :uuid
#  trust_id                     :uuid
#
# Indexes
#
#  index_schools_on_claims_service      (claims_service)
#  index_schools_on_placements_service  (placements_service)
#  index_schools_on_region_id           (region_id)
#  index_schools_on_trust_id            (trust_id)
#  index_schools_on_urn                 (urn) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (region_id => regions.id)
#  fk_rails_...  (trust_id => trusts.id)
#
require "rails_helper"

RSpec.describe Claims::School do
  context "with associations" do
    it { is_expected.to have_many(:claims) }
    it { is_expected.to have_many(:mentor_memberships) }
    it { is_expected.to have_many(:mentors).through(:mentor_memberships) }

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

  describe "default scope" do
    let!(:school_with_claims) { create(:school, :claims) }
    let!(:school_without_claims) { create(:school) }

    it "is scoped to schools using the claims service" do
      school = described_class.find(school_with_claims.id)
      expect(described_class.all).to contain_exactly(school)
      expect(described_class.all).not_to include(school_without_claims)
    end
  end
end
