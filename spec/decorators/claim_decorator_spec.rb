require "rails_helper"

RSpec.describe ClaimDecorator do
  describe "item_status_tag" do
    context "when the claim association is present" do
      it "returns the completed status tag for a claim item" do
        school = build(:claims_school)
        claim = build(:claim, school:, provider: create(:provider))

        expect(claim.decorate.item_status_tag("provider")).to eq(
          { text: "Completed", colour: "green" },
        )
      end
    end

    context "when the claim association is not present" do
      it "returns the not started status tag for a claim item" do
        school = build(:claims_school)
        claim = build(:claim, school:, provider: nil)

        expect(claim.decorate.item_status_tag("provider")).to eq(
          { text: "Not started", colour: "grey" },
        )
      end
    end
  end
end
