require "rails_helper"

RSpec.describe ClaimDecorator do
  describe "item_status_tag" do
    it "returns the completed status tag for a claim item" do
      school = create(:claims_school)
      claim = create(:claim, school:, provider: create(:provider))

      expect(claim.decorate.item_status_tag("provider")).to eq(
        { text: "Completed", colour: "green" },
      )
    end

    it "returns the not_started status tag for a claim item" do
      school = create(:claims_school)
      claim = create(:claim, school:)

      expect(claim.decorate.item_status_tag("provider")).to eq(
        { text: "Not started", colour: "grey" },
      )
    end
  end
end
