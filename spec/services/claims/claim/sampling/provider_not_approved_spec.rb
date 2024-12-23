require "rails_helper"

describe Claims::Claim::Sampling::ProviderNotApproved do
  let!(:claim) { create(:claim, :submitted, status: :sampling_in_progress) }

  describe "#call" do
    subject(:call) { described_class.call(claim:, provider_responses:) }

    context "when given no provider responses" do
      let(:provider_responses) { [] }

      it "changes to status of the claim to provider not approved" do
        expect { call }.to change(claim, :status)
          .from("sampling_in_progress")
          .to("sampling_provider_not_approved")
      end
    end

    context "when given provider responses" do
      let(:mentor_training_1) { create(:mentor_training, claim:) }
      let(:mentor_training_2) { create(:mentor_training, claim:) }
      let(:provider_responses) do
        [
          { id: mentor_training_1.id, not_assured: true, reason_not_assured: "Some reason" },
          { id: mentor_training_2.id, not_assured: false, reason_not_assured: nil },
        ]
      end

      it "updates the mentor trainings with the given response" do
        expect { call }.to change(claim, :status)
          .from("sampling_in_progress")
          .to("sampling_provider_not_approved")

        mentor_training_1.reload
        expect(mentor_training_1.not_assured).to be(true)
        expect(mentor_training_1.reason_not_assured).to eq("Some reason")
        expect(mentor_training_2.reload.not_assured).to be(false)
      end

      context "when a provider response is not given for a mentor training associated with this claim" do
        let(:provider_responses) do
          [
            { id: mentor_training_1.id, not_assured: true, reason_not_assured: "Some reason" },
          ]
        end

        before do
          mentor_training_1
          mentor_training_2
        end

        it "skips the mentor training not associated with the claim" do
          expect { call }.not_to change(mentor_training_1, :not_assured).from(false)
        end
      end
    end
  end
end
