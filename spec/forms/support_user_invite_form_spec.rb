require "rails_helper"

describe SupportUserInviteForm, type: :model do
  describe "#as_form_params" do
    it "returns form params" do
      expect(described_class.new(
        first_name: "First",
        last_name: "Last",
        email: "email@education.gov.uk",
      ).as_form_params).to eq({
        "support_user" =>
          {
            "email" => "email@education.gov.uk",
            "first_name" => "First",
            "last_name" => "Last",
          },
      })
    end
  end

  describe "#support_user" do
    let(:form_params) do
      {
        first_name: "First name",
        last_name: "Last name",
        email: "validEmail@education.gov.uk",
        service: :placements,
      }
    end
    let(:support_user_invite_form) { described_class.new(form_params) }

    context "when given attributes of a new support user" do
      it "returns a new support user" do
        expect(support_user_invite_form.support_user).to be_a_new(Placements::SupportUser)
      end
    end

    context "when given attributes of an existing support user (not discarded)" do
      it "returns a new support user" do
        create(:placements_support_user, email: "validEmail@education.gov.uk")
        expect(support_user_invite_form.support_user).to be_a_new(Placements::SupportUser)
      end
    end

    context "when given attributes of an existing discarded support user" do
      it "returns a new support user" do
        support_user = create(:placements_support_user,
                              :discarded,
                              email: "validEmail@education.gov.uk")
        expect(support_user_invite_form.support_user).to eq(support_user)
      end
    end
  end

  describe "#save!" do
    let(:support_user_invite_form) { described_class.new(form_params) }

    context "with invalid params" do
      context "with invalid user params" do
        let(:form_params) { { last_name: "Last Name", service: :placements } }

        it "returns user errors on form and does not send invite" do
          expect(support_user_invite_form.valid?).to be(false)

          expect(support_user_invite_form.errors.messages).to match(
            first_name: ["Enter a first name"],
            email: [
              "Enter an email address",
              "Enter a Department for Education email address in the correct format, like name@education.gov.uk",
            ],
          )

          expect { support_user_invite_form.save! }.to raise_error ActiveModel::ValidationError
        end
      end
    end

    context "with entirely new valid support user" do
      let(:form_params) do
        {
          first_name: "First name",
          last_name: "Last name",
          email: "validEmail@education.gov.uk",
          service: :placements,
        }
      end

      it "creates user" do
        expect { support_user_invite_form.save! }.to change(Placements::SupportUser, :count).by 1
      end
    end

    context "with a discarded support user" do
      before { discarded_support_user }

      let(:discarded_support_user) do
        create(:placements_support_user,
               :discarded,
               email: "validEmail@education.gov.uk",
               first_name: "First name",
               last_name: "Last name")
      end

      context "with the same params as the supports users attribute" do
        let(:form_params) do
          {
            first_name: "First name",
            last_name: "Last name",
            email: "validEmail@education.gov.uk",
            service: :placements,
          }
        end

        it "does not create a new user" do
          expect {
            support_user_invite_form.save!
          }.to not_change(Placements::SupportUser.with_discarded, :count)
            .and change(Placements::SupportUser, :count).by(1)
        end

        it "undiscards the support user" do
          expect {
            support_user_invite_form.save!
          }.to change { discarded_support_user.reload.discarded_at }
            .to nil
        end
      end

      context "with params different from the supports users attributes" do
        let(:form_params) do
          {
            first_name: "New first name",
            last_name: "New last name",
            email: "validEmail@education.gov.uk",
            service: :placements,
          }
        end

        it "does not create a new user" do
          expect {
            support_user_invite_form.save!
          }.to not_change(Placements::SupportUser.with_discarded, :count)
            .and change(Placements::SupportUser, :count).by(1)
        end

        it "updates user first name" do
          expect {
            support_user_invite_form.save!
          }.to change { discarded_support_user.reload.first_name }
            .from("First name").to "New first name"
        end

        it "updates user last name" do
          expect {
            support_user_invite_form.save!
          }.to change { discarded_support_user.reload.last_name }
            .from("Last name").to "New last name"
        end

        it "undiscards the support user" do
          expect {
            support_user_invite_form.save!
          }.to change { discarded_support_user.reload.discarded_at }
            .to nil
        end
      end
    end
  end
end
