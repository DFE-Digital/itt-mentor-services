require "rails_helper"

describe Placements::MentorPolicy do
  describe "scope" do
    let(:scope) { Placements::Mentor.all }

    before { create_list(:placements_mentor, 3) }

    context "when the user is a support user" do
      let(:user) { create(:placements_support_user) }

      it "returns all mentors" do
        expect(described_class::Scope.new(user, scope).resolve).to eq(scope)
      end
    end

    context "when the user is a school user" do
      let(:school) { build(:placements_school) }
      let(:user) { create(:placements_user, schools: [school]) }
      let!(:mentor_1) { create(:placements_mentor, schools: [school]) }
      let(:mentor_2) { create(:placements_mentor) }

      before do
        user.current_organisation = school
        mentor_2
      end

      it "returns the school's mentors" do
        expect(described_class::Scope.new(user, scope).resolve).to eq([mentor_1])
      end
    end

    context "when the user is none of the above" do
      let(:user) { create(:placements_user) }

      it "returns no mentors" do
        expect(described_class::Scope.new(user, scope).resolve).to be_empty
      end
    end
  end
end
