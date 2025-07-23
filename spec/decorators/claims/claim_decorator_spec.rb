require "rails_helper"

RSpec.describe Claims::ClaimDecorator do
  describe "#support_user_assigned" do
    subject(:support_user_assigned) { claim.decorate.support_user_assigned }

    let(:claim) { create(:claim, support_user:) }

    context "when the claim is assigned to a support user" do
      let(:support_user) { create(:claims_support_user, first_name: "John", last_name: "Smith") }

      it "returns the full name of the support user" do
        expect(support_user_assigned).to eq("John Smith")
      end
    end

    context "when the claim is not assigned to a support user" do
      let(:support_user) { nil }

      it "returns the full name of the support user" do
        expect(support_user_assigned).to eq("Unassigned")
      end
    end
  end
end
