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
#
# Indexes
#
#  index_schools_on_claims_service      (claims_service)
#  index_schools_on_placements_service  (placements_service)
#  index_schools_on_urn                 (urn) UNIQUE
#
require "rails_helper"

RSpec.describe Claims::School do
  context "associations" do
    it { should have_many(:claims) }

    context "#users" do
      it { should have_many(:users).through(:memberships) }

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
    end
  end
end
