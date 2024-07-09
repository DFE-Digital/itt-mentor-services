require "rails_helper"

RSpec.describe Placements::AddUserWizard do
  subject(:wizard) { described_class.new(session:, params:, organisation:, current_step: nil) }

  let(:session) { { "Placements::AddUserWizard" => state } }
  let(:state) { {} }
  let(:params_data) { {} }
  let(:params) { ActionController::Parameters.new(params_data) }
  let(:organisation) { create(:placements_school) }

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
      context "when the organisation is a school" do
        it "creates a new user, and a membership between the user and school" do
          expect { wizard.create_user }.to change(
            Placements::User, :count
          ).by(1).and change(UserMembership, :count).by(1)

          user = Placements::User.find_by(first_name:, last_name:, email:)
          expect(user.schools).to contain_exactly(organisation)
        end
      end

      context "when the organisation is a provider" do
        let(:organisation) { create(:placements_provider) }

        it "creates a new user, and a membership between the user and school" do
          expect { wizard.create_user }.to change(
            Placements::User, :count
          ).by(1).and change(UserMembership, :count).by(1)

          user = Placements::User.find_by(first_name:, last_name:, email:)
          expect(user.providers).to contain_exactly(organisation)
        end
      end
    end

    context "when the user already exists" do
      let!(:user) { create(:placements_user, first_name:, last_name:, email:) }

      context "when the organisation is a school" do
        it "creates a membership between the user and school" do
          expect { wizard.create_user }.to not_change(
            Placements::User, :count
          ).and change(UserMembership, :count).by(1)

          expect(user.schools).to contain_exactly(organisation)
        end
      end

      context "when the organisation is a provider" do
        let(:organisation) { create(:placements_provider) }

        it "creates a membership between the user and school" do
          expect { wizard.create_user }.to not_change(
            Placements::User, :count
          ).and change(UserMembership, :count).by(1)

          expect(user.providers).to contain_exactly(organisation)
        end
      end
    end

    context "when the user and membership already exist" do
      let(:user) { create(:placements_user, first_name:, last_name:, email:) }
      let(:membership) { create(:user_membership, user:, organisation:) }

      before do
        user
        membership
      end

      it "returns an error" do
        expect { wizard.create_user }.to raise_error("Invalid wizard state")
      end
    end
  end
end
