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

RSpec.describe Claims::School do
  describe "default scope" do
    let!(:school_with_claims) { create(:school, :claims) }
    let!(:school_without_claims) { create(:school) }

    it "is scoped to schools using the claims service" do
      school = described_class.find(school_with_claims.id)
      expect(described_class.all).to contain_exactly(school)
    end
  end
end
