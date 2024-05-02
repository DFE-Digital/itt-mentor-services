require "rails_helper"

RSpec.describe Placements::Partnerships::Notify do
  it_behaves_like "a service object" do
    let(:params) do
      {
        source_organisation: create(:provider),
        partner_organisation: create(:school),
      }
    end
  end

  describe "#call" do
    let(:school) { create(:school, :placements) }
    let(:provider) { create(:provider, :placements) }

    it "raises an error" do
      expect {
        described_class.call(
          source_organisation: school,
          partner_organisation: provider,
        )
      }.to raise_error(
        NoMethodError, "#nofity_user must be implemented"
      )
    end
  end
end
