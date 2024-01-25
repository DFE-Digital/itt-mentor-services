require "rails_helper"

RSpec.describe ClaimDecorator do
  describe "item_status_tag" do
    it "returns the completed status tag for a claim item" do
      school = create(:school, :claims).becomes(Claims::School)
      claim = create(:claim, school:)
      create(:mentor_training, claim:)

      expect(claim.decorate.item_status_tag("providers")).to eq(
        { text: "Completed", colour: "green" },
      )
    end

    it "returns the not_started status tag for a claim item" do
      school = create(:school, :claims).becomes(Claims::School)
      claim = create(:claim, school:)

      expect(claim.decorate.item_status_tag("providers")).to eq(
        { text: "Not started", colour: "grey" },
      )
    end
  end
end
