require "rails_helper"

describe Claims::Claim::ProviderForm, type: :model do
  let(:school) { create(:claims_school) }
  let(:existing_claim) { create(:claim, school:) }

  describe "validations" do
    context "when provider is not set" do
      it "returns invalid" do
        form = described_class.new(school:)
        expect(form.valid?).to eq(false)
        expect(form.errors.messages[:provider_id]).to include("Select a provider")
      end
    end
  end

  describe "#claim" do
    it "returns an instance of a Claims::Claim" do
      form = described_class.new(school:)
      expect(form.claim).to be_a Claims::Claim
    end

    context "when claim already exists" do
      it "returns the existing claim" do
        form = described_class.new(id: existing_claim.id, school:)
        expect(form.claim).to eq(existing_claim)
      end
    end
  end

  describe "#save" do
    let(:provider) { create(:claims_provider, :best_practice_network) }
    let(:current_user) { create(:claims_user) }

    before do
      existing_claim.mentor_trainings << create(:mentor_training, provider:)
    end

    context "when claim doesn't exist" do
      it "creates an internal draft claim with a provider" do
        form = described_class.new(provider_id: provider.id, school:, current_user:)

        expect { form.save! }.to change { form.claim.provider }.to provider

        expect(form.claim.internal_draft?).to be(true)
        expect(form.claim.created_by).to eq(current_user)
      end
    end

    context "when claim does exist" do
      it "updates the claim with the new provider" do
        form = described_class.new(id: existing_claim.id, provider_id: provider.id, school:, current_user:)

        expect { form.save! }.to change { existing_claim.reload.provider }.to provider

        expect(existing_claim.internal_draft?).to be(true)
        expect(existing_claim.created_by).not_to eq(current_user)
        expect(existing_claim.mentor_trainings.pluck(:provider_id)).to all(eq(provider.id))
      end

      context "when selecting the same provider" do
        it "doesn't update anything" do
          form = described_class.new(id: existing_claim.id, provider_id: existing_claim.provider.id, school:, current_user:)

          expect { form.save! }.to not_change { existing_claim.reload.provider }
            .and(not_change { existing_claim.reload.mentor_trainings.pluck(:provider_id) })
        end
      end
    end
  end
end
