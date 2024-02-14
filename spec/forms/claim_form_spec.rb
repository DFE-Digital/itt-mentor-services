require "rails_helper"

describe ClaimForm, type: :model do
  let(:claim) { create(:claim, :draft) }

  describe "validations" do
    it { is_expected.to validate_presence_of(:claim) }
    it { is_expected.to validate_presence_of(:claim_params) }
    it { is_expected.to validate_presence_of(:step) }

    context "when step: providers" do
      context "when provider claim params are invalid" do
        it "returns invalid" do
          form = described_class.new(claim:, step: "providers", claim_params: {})
          expect(form.valid?).to eq(false)
          expect(form.errors.messages[:provider_id]).to include("Enter a provider name")
        end
      end
    end

    context "when step: mentors" do
      context "when mentor training claim params are invalid" do
        it "returns invalid" do
          create(:mentor_training, claim:, mentor_id: nil)
          form = described_class.new(claim:, step: "mentors", claim_params: {})
          expect(form.valid?).to eq(false)
          expect(form.errors.messages[:base]).to include("Enter a mentor's name")
        end
      end
    end
  end

  describe "save" do
    context "when step: providers" do
      it "assigns a provider to the claim" do
        provider = create(:provider)
        claim_params = { provider_id: provider.id }
        form = described_class.new(claim:, step: "mentors", claim_params:)
        expect {
          form.save!
        }.to change { claim.reload.provider }.to provider
      end
    end

    context "when step: mentors" do
      it "assigns a mentor training to the claim" do
        mentor_training = create(:mentor_training, claim:)
        claim_params = { mentor_trainings_attributes: [
          {
            id: mentor_training.id,
            mentor_id: mentor_training.mentor.id,
            provider_id: mentor_training.provider.id,
          },
        ] }
        form = described_class.new(claim:, step: "mentors", claim_params:)
        expect {
          form.save!
        }.to change { claim.reload.mentor_trainings }.to [mentor_training]
      end
    end
  end
end
