require "rails_helper"

RSpec.describe "School users", service: :placements, type: :request do
  let(:school) { build(:placements_school) }
  let(:current_user) { create(:placements_user, schools: [school]) }

  before do
    sign_in_as current_user
  end

  describe "DELETE" do
    let(:school) { create(:placements_school) }

    context "when deleting a user in the same school as the current user" do
      let(:user) { create(:placements_user, schools: [school]) }

      it "deletes the user" do
        expect(school.users).to include(user)
        delete placements_school_user_path(school, user)
        expect(flash[:heading]).to eq "User deleted"
        expect(school.users).not_to include(user)
      end
    end

    context "when the current user tries to delete themselves" do
      it "shows an error message" do
        delete placements_school_user_path(school, current_user)
        expect(flash[:heading]).to eq "You cannot perform this action"
        expect(flash[:success]).to be false
        expect(school.users).to include(current_user)
      end
    end

    context "when deleting a user in a different school" do
      let(:another_school) { build(:placements_school) }
      let(:user) { create(:placements_user, schools: [another_school]) }

      it "shows an error message" do
        expect {
          delete placements_school_user_path(another_school, user)
        }.to raise_exception(ActiveRecord::RecordNotFound)
        expect(another_school.users).to include(user)
      end
    end
  end
end
