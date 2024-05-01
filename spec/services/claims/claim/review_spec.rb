require "rails_helper"

describe Claims::Claim::Review do
  subject(:service) { described_class.call(claim:) }

  let!(:claim) { create(:claim, reference: nil, status: :internal_draft, school:) }
  let(:school) { create(:claims_school, urn: "1234") }

  it_behaves_like "a service object" do
    let(:params) { { claim: } }
  end

  describe "#call" do
    it "sets the reviewed attribute to true" do
      expect { service }.to change(claim, :reviewed).from(false).to(true)
    end
  end
end
