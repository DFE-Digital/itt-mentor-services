# == Schema Information
#
# Table name: schools
#
#  id         :uuid             not null, primary key
#  claims     :boolean          default(FALSE)
#  placements :boolean          default(FALSE)
#  urn        :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_schools_on_claims      (claims)
#  index_schools_on_placements  (placements)
#  index_schools_on_urn         (urn) UNIQUE
#
require "rails_helper"

RSpec.describe School, type: :model do
  context "associations" do
    it do
      should belong_to(:gias_school).with_foreign_key(:urn).with_primary_key(
        :urn,
      )
      should have_many(:memberships)
    end
  end

  context "validations" do
    subject { create(:school) }

    it { is_expected.to validate_presence_of(:urn) }
    it { is_expected.to validate_uniqueness_of(:urn).case_insensitive }
  end

  context "delegations" do
    subject { create(:school) }
    it "delegates all missing methods to gias model" do
      GIAS_METHODS.each do |gias_method|
        expect(subject.respond_to?(gias_method)).to eq true
      end
    end
  end

  context "scopes" do
    describe "services" do
      let!(:placements_on) { create(:school, placements: true) }
      let!(:claims_on) { create(:school, claims: true) }
      describe "#placements" do
        it "only returns schools in the placements service" do
          expect(described_class.placements).to contain_exactly(placements_on)
        end
      end

      describe "#claims" do
        it "only returns schools in the claims service" do
          expect(described_class.claims).to contain_exactly(claims_on)
        end
      end
    end
  end
end

GIAS_METHODS =
  %i[name
     town
     postcode
     ukprn
     address1
     address2
     address3
     website
     telephone
     group
     type_of_establishment
     phase
     gender
     minimum_age
     maximum_age
     religious_character
     admissions_policy
     urban_or_rural
     school_capacity
     total_pupils
     total_boys
     total_girls
     percentage_free_school_meals
     special_classes
     send_provision
     rating
     last_inspection_date
     email_address
     training_with_disabilities
     postcode
     town
     telephone
     website
     address1
     address2
     address3].freeze
