require "rails_helper"

describe Claims::Claim::Sampling::HoursOverridden do
  subject(:call) { described_class.call(claim:, provider_responses:, current_user:) }

  let(:current_user) { create(:claims_support_user) }
  let(:claim) do
    create(:claim, :submitted, status: :sampling_provider_not_approved, amendment_notification_sent_at: 3.days.ago)
  end
  let!(:amended_training) do
    create(:mentor_training, claim:, hours_completed: 15, not_assured: true, reason_not_assured: "Provider reason", hours_clawed_back: 4)
  end
  let!(:other_training) { create(:mentor_training, claim:, hours_completed: 10) }
  let(:provider_responses) do
    [
      { id: amended_training.id, not_assured: true, reason_not_assured: "Evidence from school", hours_clawed_back: 7 },
      { id: other_training.id, not_assured: true, reason_not_assured: "No training took place", hours_clawed_back: 10 },
    ]
  end

  it "updates the hours and reasons on the mentor trainings" do
    call

    expect(amended_training.reload).to have_attributes(
      hours_clawed_back: 7,
      reason_not_assured: "Evidence from school",
      reason_clawed_back: "Evidence from school",
    )
    expect(other_training.reload).to have_attributes(
      not_assured: true,
      hours_clawed_back: 10,
      reason_clawed_back: "No training took place",
    )
  end

  it "moves the claim to clawback approval, requested by the support user" do
    call

    expect(claim.reload).to have_attributes(status: "clawback_requires_approval", clawback_requested_by: current_user)
  end

  context "when a mentor training is no longer amended" do
    let(:provider_responses) do
      [
        { id: amended_training.id, not_assured: false, reason_not_assured: nil, hours_clawed_back: nil },
        { id: other_training.id, not_assured: true, reason_not_assured: "No training took place", hours_clawed_back: 10 },
      ]
    end

    it "reverts it to the originally claimed hours" do
      call

      expect(amended_training.reload).to have_attributes(not_assured: false, reason_not_assured: nil, hours_clawed_back: nil)
    end
  end

  context "when no hours are clawed back" do
    let(:provider_responses) do
      [
        { id: amended_training.id, not_assured: false, reason_not_assured: nil, hours_clawed_back: nil },
        { id: other_training.id, not_assured: false, reason_not_assured: nil, hours_clawed_back: nil },
      ]
    end

    it "moves the claim to paid" do
      call

      expect(claim.reload).to be_paid
    end
  end
end
