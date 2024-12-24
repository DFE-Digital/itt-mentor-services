require "rails_helper"

RSpec.describe Claims::ClaimHelper do
  describe "#claim_statuses_for_selection" do
    it "returns an array of claims statuses, except draft statuses" do
      expect(claim_statuses_for_selection).to contain_exactly(
        "submitted",
        "payment_in_progress",
        "payment_information_requested",
        "payment_information_sent",
        "paid",
        "payment_not_approved",
        "sampling_in_progress",
        "sampling_provider_not_approved",
        "sampling_not_approved",
        "clawback_requested",
        "clawback_in_progress",
        "clawback_complete",
      )
    end
  end

  describe "#claim_provider_response" do
    let(:claim) { create(:claim, :submitted, status: :sampling_provider_not_approved) }

    context "when the claim has no 'not_assured' mentor trainings" do
      it "returns an empty string" do
        expect(claim_provider_response(claim)).to eq("")
      end
    end

    context "when the claim has 'not_assured' mentor trainings" do
      let(:mentor_john_smith) { create(:claims_mentor, first_name: "John", last_name: "Smith") }
      let(:mentor_jane_doe) { create(:claims_mentor, first_name: "Jane", last_name: "Doe") }
      let(:mentor_joe_bloggs) { create(:claims_mentor, first_name: "Joe", last_name: "Bloggs") }
      let(:john_smith_mentor_training) do
        create(
          :mentor_training,
          mentor: mentor_john_smith,
          claim:,
          hours_completed: 20,
          not_assured: true,
          reason_not_assured: "Some reason",
        )
      end

      let(:jane_doe_mentor_training) do
        create(
          :mentor_training,
          mentor: mentor_jane_doe,
          claim:,
          hours_completed: 20,
          not_assured: true,
          reason_not_assured: "Another reason",
        )
      end
      let(:joe_bloggs_mentor_training) do
        create(
          :mentor_training,
          mentor: mentor_joe_bloggs,
          claim:,
          hours_completed: 20,
        )
      end

      before do
        john_smith_mentor_training
        jane_doe_mentor_training
        joe_bloggs_mentor_training
      end

      it "returns a list of the not assured mentors and the providers reason" do
        expect(claim_provider_response(claim)).to eq(
          "<ul class=\"govuk-list\"><li>Jane Doe: Another reason</li><li>John Smith: Some reason</li></ul>",
        )
      end
    end
  end
end
