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

  describe "#formatted_inspection_date" do
    it "returns nicely formatted date" do
      gias_school = create(:gias_school, last_inspection_date: Date.new(2020, 10, 12))

      expect(build(:school, gias_school:).decorate.formatted_inspection_date).to eq("12 October 2020")
    end
  end
end
