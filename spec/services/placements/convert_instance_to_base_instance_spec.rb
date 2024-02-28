require "rails_helper"

RSpec.describe Placements::ConvertInstanceToBaseInstance do
  describe "#call" do
    let(:placements_school) { create(:placements_school) }
    let(:school) { create(:school) }

    context "when the object has a base class" do
      it "returns the base class for a school", :aggregate_failures do
        expect(placements_school).to be_a(Placements::School)
        expect(described_class.call(placements_school)).to be_a(School)
      end
    end

    context "when the object has no base class" do
      it "returns the base class for a user", :aggregate_failures do
        expect(school).to be_a(School)
        expect(described_class.call(school)).to be_a(School)
      end
    end

    context "when the object does not respond to base_class" do
      it "raises an ArgumentError" do
        expect { described_class.call("not an object") }
          .to raise_error(Placements::ConvertInstanceToBaseInstance::ArgumentError, "Object must respond to base_class.")
      end
    end
  end
end
