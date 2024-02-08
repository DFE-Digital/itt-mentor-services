require "rails_helper"

describe UserInviteForm, type: :model do
  describe "#as_form_params" do
    it "returns form params" do
      expect(described_class.new(
        first_name: "First",
        last_name: "Last",
        email: "email@email.org.uk",
      ).as_form_params).to eq({
        "user_invite_form" =>
          {
            "email" => "email@email.org.uk",
            "first_name" => "First",
            "last_name" => "Last",
          },
      })
    end
  end

  describe "#user" do
    let(:form_params) do
      {
        first_name: "First name",
        last_name: "Last name",
        email: "validEmail@email.com",
        service:,
      }
    end
    let(:user_invite_form) { described_class.new(form_params) }

    context "with service: placements" do
      let(:service) { :placements }

      context "when given attributes of a new placements user" do
        it "returns a new support user" do
          expect(user_invite_form.user).to be_a_new(Placements::User)
        end
      end
    end

    context "with service: claims" do
      let(:service) { :claims }

      context "when given attributes of a new claims user" do
        it "returns a new support user" do
          expect(user_invite_form.user).to be_a_new(Claims::User)
        end
      end
    end
  end

  describe "#save!" do
    let(:user_invite_form) { described_class.new(form_params) }

    context "with invalid params" do
      context "with invalid user params" do
        let(:organisation) { create(:school, :placements) }
        let(:form_params) { { last_name: "Last Name", organisation:, service: :placements } }

        it "returns user errors on form and does not send invite" do
          expect(user_invite_form.valid?).to eq false

          expect(user_invite_form.errors.messages).to match(
            first_name: ["Enter a first name"],
            email: ["Enter an email address", "Enter an email address in the correct format, like name@example.com"],
          )
          expect { user_invite_form.save! }.to raise_error ActiveModel::ValidationError
        end
      end

      context "when membership already exists" do
        let(:user) { create(:placements_user) }
        let(:organisation) { create(:school, :placements) }
        let(:form_params) do
          {
            first_name: user.first_name,
            last_name: user.last_name,
            email: user.email,
            organisation:,
            service: :placements,
          }
        end

        it "returns membership error on the email attribute of the for and does not send invite" do
          create(:user_membership, user:, organisation:)
          expect(user_invite_form.valid?).to eq false

          expect(user_invite_form.errors.messages)
            .to match(email: ["Email address already in use"])
          expect { user_invite_form.save! }.to raise_error ActiveModel::ValidationError
        end
      end
    end

    context "with entirely new valid user" do
      let(:organisation) { create(:school, :placements) }
      let(:form_params)  do
        {
          first_name: "First name",
          last_name: "Last name",
          email: "validEmail@email.com",
          organisation:,
          service: :placements,
        }
      end

      it "creates user" do
        expect { user_invite_form.save! }.to change(User, :count).by 1
      end

      it "creates membership" do
        expect { user_invite_form.save! }.to change(UserMembership, :count).by 1
      end
    end

    context "with user belonging to another organisation" do
      let(:organisation) { create(:placements_provider) }
      let(:user) { create(:placements_user) }
      let(:membership) { create(:user_membership, organisation:, user:) }
      let(:another_organisation) { create(:placements_provider) }

      let(:form_params) do
        {
          first_name: "New first name",
          last_name: user.last_name,
          email: user.email,
          organisation: another_organisation,
          service: :placements,
        }
      end

      it "updates user first name" do
        expect { user_invite_form.save! }.to change { user.reload.first_name }.to "New first name"
      end

      it "creates membership" do
        expect { user_invite_form.save! }.to change(UserMembership, :count).by 1
      end
    end
  end
end
