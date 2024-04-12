require "rails_helper"

describe ProviderOnboardingForm, type: :model do
  describe "validations" do
    context "when id is not present" do
      it "returns invalid" do
        form = described_class.new(id: nil)
        expect(form.valid?).to eq(false)
        expect(form.valid?).to eq(false)
        expect(form.errors.messages[:id]).to include("Enter a provider name, UKPRN, URN or postcode")
      end
    end

    context "when given an id not associated with a provider" do
      it "returns invalid" do
        form = described_class.new(id: "1231")
        expect(form.valid?).to eq(false)
        expect(form.errors.messages[:id]).to include("Enter a provider name, UKPRN, URN or postcode")
      end
    end

    context "when given an id for a provider already onboarded" do
      it "returns invalid" do
        provider = create(:placements_provider)
        form = described_class.new(id: provider.id)
        expect(form.valid?).to eq(false)
        expect(form.errors.messages[:id]).to include("#{provider.name} has already been added. Try another provider")
      end
    end

    context "when given a urn for a provider not onboarded" do
      it "returns valid" do
        provider = create(:provider)
        form = described_class.new(id: provider.id)
        expect(form.valid?).to eq(true)
      end
    end
  end

  describe "delegations" do
    describe "#name" do
      context "when provider is nil" do
        it "returns nil" do
          form = described_class.new
          expect(form.name).to eq(nil)
        end
      end

      context "when provider exists" do
        it "returns then name of the provider" do
          provider = create(:provider, name: "Provider 1")
          form = described_class.new(id: provider.id)
          expect(form.name).to eq("Provider 1")
        end
      end
    end
  end

  describe "#provider" do
    context "when given the urn of an existing provider" do
      it "returns the provider associated with that urn" do
        provider = create(:provider)
        expect(described_class.new(id: provider.id).provider).to eq(provider)
      end
    end

    context "when given a urn not associated with a provider" do
      it "returns nil" do
        expect(described_class.new(id: "123").provider).to eq(nil)
      end
    end
  end

  describe "save!" do
    it "enables the boolean flag for placements" do
      provider = create(:provider)
      onboarding = expect do
        described_class.new(id: provider.id).save!
        provider.reload
      end
      onboarding.to change(provider, :placements_service).from(false).to(true)
    end
  end

  describe "as_form_params" do
    it "returns form params" do
      expect(described_class.new(
        id: "1234",
        javascript_disabled: true,
      ).as_form_params).to eq({
        "provider" =>
          {
            id: "1234",
            javascript_disabled: true,
          },
      })
    end
  end
end
