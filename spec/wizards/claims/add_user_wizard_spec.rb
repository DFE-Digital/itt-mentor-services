require "rails_helper"

RSpec.describe Claims::AddUserWizard do
  subject(:wizard) { described_class.new(state:, params:, organisation: school, current_step: nil) }

  let(:state) { {} }
  let(:params_data) { {} }
  let(:params) { ActionController::Parameters.new(params_data) }
  let(:school) { create(:claims_school) }

  describe "#steps" do
    subject { wizard.steps.keys }

    it { is_expected.to eq %i[user check_your_answers] }
  end

  describe "#create_user" do
    subject(:create_user) { wizard.create_user }

    let(:first_name) { "John" }
    let(:last_name) { "Doe" }
    let(:email) { "joe_doe@example.com" }
    let(:state) do
      {
        "user" => {
          "first_name" => first_name,
          "last_name" => last_name,
          "email" => email,
        },
      }
    end

    context "when the user does not already exist" do
      it "creates a new user, and a membership between the user and school" do
        expect { create_user }.to change(
          Claims::User, :count
        ).by(1).and change(UserMembership, :count).by(1)

        user = Claims::User.find_by(first_name:, last_name:, email:)
        expect(user.schools).to contain_exactly(school)
      end
    end

    context "when the user already exists" do
      let!(:user) { create(:claims_user, first_name:, last_name:, email:) }

      it "creates a membership between the user and school" do
        expect { create_user }.to not_change(
          Claims::User, :count
        ).and change(UserMembership, :count).by(1)

        expect(user.schools).to contain_exactly(school)
      end
    end

    context "when the user and membership already exist" do
      let(:user) { create(:claims_user, first_name:, last_name:, email:) }
      let(:membership) { create(:user_membership, user:, organisation: school) }

      before do
        user
        membership
      end

      it "returns an error" do
        expect { create_user }.to raise_error("Invalid wizard state")
      end
    end
  end
end
