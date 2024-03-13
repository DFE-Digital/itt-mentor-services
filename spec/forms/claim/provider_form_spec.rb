require "rails_helper"

describe Claim::ProviderForm, type: :model do
  let!(:school) { create(:claims_school) }
  let!(:provider) { create(:provider, :best_practice_network) }
  let!(:claim) { create(:claim, school:) }
  let!(:current_user) { create(:claims_user) }

  describe "validations" do
    context "when provider is not set" do
      it "returns invalid" do
        form = described_class.new(school:)
        expect(form.valid?).to eq(false)
        expect(form.errors.messages[:provider_id]).to include("Select a provider")
      end
    end
  end

  describe "#to_model" do
    it "returns an instance of a Claim" do
      form = described_class.new(school:)
      expect(form.to_model).to be_a Claim
    end
  end

  describe "#claim" do
    it "returns an instance of a Claim" do
      form = described_class.new(school:)
      expect(form.claim).to be_a Claim
    end

    context "when claim already exists" do
      it "returns the existing claim" do
        form = described_class.new(id: claim.id, school:)
        expect(form.claim).to eq(claim)
      end
    end
  end

  describe "save" do
    context "when claim doesn't exist" do
      it "creates an internal claim with a provider" do
        form = described_class.new(provider_id: provider.id, school:, current_user:)

        expect {
          form.save!
        }.to change { form.claim.provider }.to provider
        expect(form.claim.internal?).to be(true)
        expect(form.claim.created_by).to eq(current_user)
      end
    end

    context "when claim does exist" do
      it "creates an internal claim with a provider" do
        form = described_class.new(id: claim.id, provider_id: provider.id, school:, current_user:)

        expect {
          form.save!
        }.to change { claim.reload.provider }.to provider
        expect(claim.internal?).to be(true)
        expect(form.claim.created_by).to eq(current_user)
      end
    end
  end
end
