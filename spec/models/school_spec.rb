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

RSpec.describe School, type: :model do
  context "associations" do
    it { should have_many(:memberships) }
    it { should have_many(:mentors) }
  end

  context "scopes" do
    describe "#placements_service" do
      it "only returns placements schools" do
        create(:school, :claims)
        create(:school)
        placements_school = create(:school, :placements)

        expect(described_class.placements_service).to contain_exactly(placements_school)
      end
    end

    describe "#claims_school" do
      it "only returns claims schools" do
        create(:school, :placements)
        create(:school)
        claims_school = create(:school, :claims)

        expect(described_class.claims_service).to contain_exactly(claims_school)
      end
    end

    describe "#claims_service" do
    end
  end

  context "validations" do
    subject { create(:school) }

    it { is_expected.to validate_presence_of(:urn) }
    it { is_expected.to validate_uniqueness_of(:urn).case_insensitive }
  end
end
