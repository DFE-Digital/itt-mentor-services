require "rails_helper"

describe Claims::Claim::Clawback::MoveToClawback do
  include ActiveJob::TestHelper

  subject(:call) { described_class.call(claim:, current_user:) }

  around do |example|
    perform_enqueued_jobs { example.run }
  end

  let(:claim) { create(:claim, :submitted, status: :sampling_provider_not_approved, amendment_notification_sent_at: 60.days.ago) }
  let(:current_user) { create(:claims_support_user) }
  let(:school_user) { create(:claims_user, schools: [claim.school]) }
  let(:amended_training) do
    create(:mentor_training, claim:, hours_completed: 20, hours_clawed_back: 8, not_assured: true, reason_not_assured: "Only 12 hours worked")
  end
  let(:assured_training) { create(:mentor_training, claim:, hours_completed: 10) }

  before do
    amended_training
    assured_training
    school_user
    allow(Claims::UserMailer).to receive(:claim_requires_clawback).and_return(instance_double(ActionMailer::MessageDelivery, deliver_later: true))
  end

  it "moves the claim to clawback requires approval, requested by the current user" do
    expect { call }.to change(claim, :status)
      .from("sampling_provider_not_approved")
      .to("clawback_requires_approval")
      .and change(claim, :clawback_requested_by).to(current_user)
  end

  it "keeps the hours clawed back from the provider's amended hours and uses their reason" do
    call

    expect(amended_training.reload.hours_clawed_back).to eq(8)
    expect(amended_training.reason_clawed_back).to eq("Only 12 hours worked")
    expect(claim.total_clawback_amount).to eq(amended_training.clawback_amount)
  end

  it "leaves mentor trainings the provider did not amend untouched" do
    call

    expect(assured_training.reload.hours_clawed_back).to be_nil
    expect(assured_training.reason_clawed_back).to be_nil
  end

  it "records a clawback requested activity" do
    expect { call }.to change(Claims::ClaimActivity, :count).by(1)

    expect(Claims::ClaimActivity.last).to have_attributes(action: "clawback_requested", user: current_user, record: claim)
  end

  it "notifies the school users" do
    call

    expect(Claims::UserMailer).to have_received(:claim_requires_clawback).with(school_user, claim)
  end
end
