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

  describe "#invite!" do
    context "with invalid params" do
      it "does not send invitation" do
        expect(UserMailer).not_to receive(:invitation_email)
      end

      context "with invalid user params" do
        it "returns user errors on form and does not send invite" do
          organisation = create(:school, :placements)
          form_params = { last_name: "Last Name", organisation:, service: :placements }
          user_invite_form = described_class.new(form_params)
          expect(user_invite_form.valid?).to eq false
          expect(user_invite_form.errors.messages).to match(
            first_name: ["Enter a first name"],
            email: ["Enter an email address", "Enter an email address in the correct format, like name@example.com"],
          )
          expect { user_invite_form.invite! }.to raise_error ActiveRecord::RecordInvalid
        end
      end

      context "when membership already exists" do
        it "returns membership error on the email attribute of the for and does not send invite" do
          user = create(:placements_user)
          organisation = create(:school, :placements)
          create(:membership, user:, organisation:)
          form_params = {
            first_name: user.first_name,
            last_name: user.last_name,
            email: user.email,
            organisation:,
            service: :placements,
          }
          user_invite_form = described_class.new(form_params)
          expect(user_invite_form.valid?).to eq false
          expect(user_invite_form.errors.messages)
            .to match(email: ["Email address already in use"])
          expect { user_invite_form.invite! }.to raise_error ActiveRecord::RecordInvalid
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

      it "sends invitation" do
        user_invite_form = described_class.new(form_params)
        expect { user_invite_form.invite! }.to have_enqueued_mail(UserMailer, :invitation_email)
      end

      it "creates user" do
        user_invite_form = described_class.new(form_params)
        expect { user_invite_form.invite! }.to change(User, :count).by 1
      end

      it "creates membership" do
        user_invite_form = described_class.new(form_params)
        expect { user_invite_form.invite! }.to change(Membership, :count).by 1
      end
    end

    context "with user belonging to another organisation" do
      let(:organisation) { create(:placements_provider) }
      let(:user) { create(:placements_user) }
      let(:membership) { create(:membership, organisation:, user:) }
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

      it "sends invitation" do
        user_invite_form = described_class.new(form_params)
        expect { user_invite_form.invite! }.to have_enqueued_mail(UserMailer, :invitation_email)
      end

      it "updates user first name" do
        user_invite_form = described_class.new(form_params)
        user_invite_form.invite!
        expect(user.reload.first_name).to eq "New first name"
      end

      it "creates membership" do
        user_invite_form = described_class.new(form_params)
        expect { user_invite_form.invite! }.to change(Membership, :count).by 1
      end
    end
  end
end
