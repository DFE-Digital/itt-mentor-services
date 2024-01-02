require "rails_helper"

RSpec.describe SchoolDecorator do
  describe "#formatted_address" do
    it "returns a formatted address" do
      gias_school = create(:gias_school,
                           address1: "A School",
                           address2: "The School Road",
                           address3: "Somewhere",
                           town: "London",
                           postcode: "LN12 1LN")

      expect(
        build(:school, gias_school:).decorate.formatted_address,
      ).to eq(
        "A School<br/>The School Road<br/>Somewhere<br/>London<br/>LN12 1LN",
      )
    end
  end
end
