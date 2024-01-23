require "rails_helper"

RSpec.describe Placements::School do
  describe "default scope" do
    let!(:school_with_placements) { create(:school, :placements) }
    let!(:school_without_placements) { create(:school) }

    it "is scoped to schools using the placement service" do
      school = described_class.find(school_with_placements.id)
      expect(described_class.all).to contain_exactly(school)
    end
  end
end
