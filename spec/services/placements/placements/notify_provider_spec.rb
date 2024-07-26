require "rails_helper"

RSpec.describe Placements::Placements::NotifyProvider do
  subject(:notify_provider_service) { described_class.call(provider:, placement:) }

  it_behaves_like "a service object" do
    let(:params) { { provider: create(:provider), placement: create(:placement) } }
  end

  describe "#call" do
    let(:placement) { create(:placement) }

    context "when the provider is not onboarded onto the placements service" do
      let(:provider) { create(:provider) }

      it "returns nil" do
        expect(notify_provider_service).to be_nil
      end
    end

    context "when the provider is onboarded onto the placements service" do
      let(:provider) { create(:placements_provider) }

      it "raises an error" do
        expect {
          notify_provider_service
        }.to raise_error(
          NoMethodError, "#notify_users must be implemented"
        )
      end
    end
  end
end