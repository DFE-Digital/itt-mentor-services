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
#
# Indexes
#
#  index_schools_on_claims_service      (claims_service)
#  index_schools_on_placements_service  (placements_service)
#  index_schools_on_region_id           (region_id)
#  index_schools_on_urn                 (urn) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (region_id => regions.id)
#
require "rails_helper"

RSpec.describe Placements::School do
  context "assocations" do
    describe "#users" do
      it { is_expected.to have_many(:users).through(:memberships) }

      it "returns only Placements::User records" do
        placements_school = create(:placements_school)
        placements_user = create(:placements_user)

        placements_school.users << create(:claims_user)
        placements_school.users << placements_user

        expect(placements_school.users).to contain_exactly(placements_user)
        expect(placements_school.users).to all(be_a(Placements::User))
      end
    end
  end

  describe "default scope" do
    let!(:school_with_placements) { create(:school, :placements) }
    let!(:school_without_placements) { create(:school) }

    it "is scoped to schools using the placement service" do
      school = described_class.find(school_with_placements.id)
      expect(described_class.all).to contain_exactly(school)
    end
  end
end
