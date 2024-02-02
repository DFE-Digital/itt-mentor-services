require "rails_helper"

RSpec.describe Claims::SchoolPolicy::Scope do
  subject { described_class.new(user, Claims::School).resolve }

  let!(:non_associated_school) { create(:claims_school) }
  let!(:associated_school) { create(:claims_school) }

  context "when user is a support user" do
    let(:user) { create(:claims_support_user) }

    it "returns all schools" do
      expect(subject).to match_array([non_associated_school, associated_school])
    end
  end

  context "when user is not a support user" do
    let(:user) { create(:claims_user) }

    before do
      user.schools << associated_school
    end

    it "returns schools that the user is associated with" do
      expect(subject).to match_array([associated_school])
    end
  end
end
