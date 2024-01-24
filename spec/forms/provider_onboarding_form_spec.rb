require "rails_helper"

describe ProviderOnboardingForm, type: :model do
  describe "validations" do
    it { should validate_presence_of(:code) }

    context "when given a code not associated with a provider" do
      it "returns invalid" do
        form = described_class.new(code: "random")
        expect(form.valid?).to eq(false)
        expect(form.errors.messages[:code]).to include("Enter a provider name, UKPRN, URN or postcode")
      end
    end

    context "when given a code for a provider already onboarded" do
      it "returns invalid" do
        provider = create(:placements_provider)
        form = described_class.new(code: provider.code)
        expect(form.valid?).to eq(false)
        expect(form.errors.messages[:code]).to include("#{provider.name} has already been added. Try another provider")
      end
    end

    context "when given a urn for a provider not onboarded" do
      it "returns valid" do
        provider = create(:provider)
        form = described_class.new(code: provider.code)
        expect(form.valid?).to eq(true)
      end
    end
  end

  describe "#provider" do
    context "when given the urn of an existing provider" do
      it "returns the provider associated with that urn" do
        provider = create(:provider)
        expect(described_class.new(code: provider.code).provider).to eq(provider)
      end
    end

    context "when given a urn not associated with a provider" do
      it "returns nil" do
        expect(described_class.new(code: "random").provider).to eq(nil)
      end
    end
  end

  describe "onboard" do
    it "enables the boolean flag for placements" do
      provider = create(:provider)
      onboarding = expect do
        described_class.new(code: provider.code).onboard
        provider.reload
      end
      onboarding.to change(provider, :placements_service).from(false).to(true)
    end
  end
end
