require "rails_helper"

RSpec.describe SchoolDecorator do
  describe "#formatted_address" do
    it "returns a formatted address" do
      school = build(:school,
                     address1: "A School",
                     address2: "The School Road",
                     address3: "Somewhere",
                     town: "London",
                     postcode: "LN12 1LN")

      expect(school.decorate.formatted_address).to eq(
        "<p>A School\n<br />The School Road\n<br />Somewhere\n<br />London\n<br />LN12 1LN</p>",
      )
    end

    context "when attributes are missing" do
      it "returns a formatted address based on the present attributes" do
        school = build(:school,
                       address1: "A School",
                       address2: "The School Road",
                       address3: "Somewhere",
                       postcode: "LN12 1LN")
        expect(school.decorate.formatted_address).to eq(
          "<p>A School\n<br />The School Road\n<br />Somewhere\n<br />LN12 1LN</p>",
        )
      end
    end
  end

  describe "#formatted_inspection_date" do
    it "returns nicely formatted date" do
      school = build(:school, last_inspection_date: Date.new(2020, 10, 12))

      expect(school.decorate.formatted_inspection_date).to eq("12 October 2020")
    end
  end

  describe "#age_range" do
    it "return the minimum age and maximum age as a sentence" do
      school = build(:school, minimum_age: 4, maximum_age: 11)

      expect(school.decorate.age_range).to eq("4 to 11")
    end
  end
end
