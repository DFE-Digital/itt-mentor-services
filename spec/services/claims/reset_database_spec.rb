require "rails_helper"

RSpec.describe Claims::ResetDatabase do
  describe "#call" do
    let(:school) { create(:claims_school, claims_grant_conditions_accepted_at: Time.current) }

    before do
      create(:claim, school:)
      create(:claims_mentor_membership, school:)
    end

    it "removes all claims and mentor memberships and resets all grant conditions acceptances for all schools" do
      expect { described_class.call }.to change(Claims::Claim, :count).by(-1)
        .and change(Claims::MentorMembership, :count).by(-1)
        .and change { school.reload.claims_grant_conditions_accepted_at }.to(nil)
    end

    it "does nothing in Production" do
      allow(HostingEnvironment).to receive(:env).and_return(ActiveSupport::EnvironmentInquirer.new("production"))

      expect { described_class.call }.to not_change(Claims::Claim, :count)
        .and not_change(Claims::MentorMembership, :count)
        .and(not_change { school.reload.claims_grant_conditions_accepted_at })
    end
  end
end
