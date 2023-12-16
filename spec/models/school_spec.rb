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
      should have_one(:gias_school).with_foreign_key(:urn).with_primary_key(
               :urn
             )
    end
  end

  context "validations" do
    subject { create(:school) }

    it { is_expected.to validate_presence_of(:urn) }
    it { is_expected.to validate_uniqueness_of(:urn).case_insensitive }
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
