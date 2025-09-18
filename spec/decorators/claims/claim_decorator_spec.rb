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

  describe "#provider_responses" do
    subject(:provider_responses) { claim.decorate.provider_responses }

    let(:claim) { create(:claim, school:) }
    let(:school) { build(:claims_school) }
    let(:mentor_1) { build(:claims_mentor, schools: [school], first_name: "Jane", last_name: "Doe") }
    let(:mentor_2) { build(:claims_mentor, schools: [school], first_name: "John", last_name: "Smith") }
    let(:mentor_training_1) do
      create(:mentor_training,
             :not_assured,
             claim:,
             mentor: mentor_1,
             reason_not_assured: "ECT Mentor")
    end
    let(:mentor_training_2) do
      create(:mentor_training,
             :not_assured,
             claim:,
             mentor: mentor_2,
             reason_not_assured: "Mentor not recognised")
    end

    before do
      mentor_training_1
      mentor_training_2
    end

    it "returns the providers responses" do
      expect(provider_responses).to eq("- Jane Doe: ECT Mentor\n- John Smith: Mentor not recognised\n")
    end
  end
end
