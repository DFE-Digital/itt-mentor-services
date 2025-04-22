require "rails_helper"

RSpec.describe Placements::HostingInterestDecorator do
  let(:hosting_interest) { build(:hosting_interest, appetite:) }
  let(:appetite) { "actively_looking" }

  describe "#status" do
    subject(:status) { hosting_interest.decorate.status }

    context "when the hosting interest is 'actively_looking'" do
      it "returns 'Open to hosting'" do
        expect(status).to eq("Open to hosting")
      end
    end

    context "when the hosting interest is 'interested'" do
      let(:appetite) { "interested" }

      it "returns 'Interested'" do
        expect(status).to eq("Interested")
      end
    end

    context "when the hosting interest is 'not_open'" do
      let(:appetite) { "not_open" }

      it "returns 'Interested'" do
        expect(status).to eq("Not open")
      end
    end
  end
end
