require "rails_helper"

RSpec.describe Placements::AddSupportUserWizard do
  subject(:wizard) { described_class.new(state:, params:, current_step: nil) }

  let(:state) { {} }
  let(:params_data) { {} }
  let(:params) { ActionController::Parameters.new(params_data) }

  describe "#steps" do
    subject { wizard.steps.keys }

    it { is_expected.to eq %i[support_user check_your_answers] }
  end

  describe "#create_support_user" do
    subject(:create_support_user) { wizard.create_support_user }

    let(:first_name) { "John" }
    let(:last_name) { "Doe" }
    let(:email) { "john.doe@education.gov.uk" }
    let(:state) do
      {
        "support_user" => {
          "first_name" => first_name,
          "last_name" => last_name,
          "email" => email,
        },
      }
    end

    context "when the support user does not already exist" do
      it "creates a new support user" do
        expect { create_support_user }.to change(
          Placements::SupportUser, :count
        ).by(1)

        support_user = Placements::SupportUser.find_by(first_name:, last_name:, email:)
        expect(support_user).to be_present
      end
    end

    context "when the support user already exists" do
      before { create(:placements_support_user, first_name:, last_name:, email:) }

      it "raises an error" do
        expect { create_support_user }.to raise_error("Invalid wizard state")
      end
    end

    context "when the support user has been discarded" do
      let(:support_user) { create(:placements_support_user, first_name:, last_name:, email:) }

      before do
        support_user.discard
      end

      it "undiscards the support user" do
        expect { create_support_user }.to change(
          Placements::SupportUser, :count
        ).by(1)

        support_user.reload
        expect(support_user.discarded?).to be(false)
      end

      context "when the first name or last name do not match the record attributes" do
        let(:support_user) do
          create(:placements_support_user,
                 first_name: "Jake",
                 last_name: "Bloggs",
                 email:)
        end

        it "updates the existing support user record's first and last name" do
          expect { create_support_user }.to change(
            Placements::SupportUser, :count
          ).by(1)

          support_user.reload
          expect(support_user.discarded?).to be(false)
          expect(support_user.first_name).to eq(first_name)
          expect(support_user.last_name).to eq(last_name)
        end
      end
    end
  end
end
