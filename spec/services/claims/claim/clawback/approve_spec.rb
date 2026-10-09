require "rails_helper"

describe Claims::Claim::Clawback::Approve do
  subject(:call) { described_class.call(claim:, current_user:) }

  let(:claim) { create(:claim, :submitted, status: :clawback_requires_approval) }
  let(:current_user) { create(:claims_support_user) }

  it "moves the claim to clawback requested, approved by the current user" do
    expect { call }.to change(claim, :status)
      .from("clawback_requires_approval")
      .to("clawback_requested")
      .and change(claim, :clawback_approved_by).to(current_user)
  end
end
