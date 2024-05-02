require "rails_helper"

RSpec.describe SupportUserMailer, type: :mailer do
  describe "#support_user_invitation" do
    context "when inviting a user to the claims service" do
      subject(:invite_email) { described_class.with(service: "claims").support_user_invitation(user) }

      let(:user) { create(:claims_support_user, first_name: "John", last_name: "Doe") }

      it "is addressed to the user's email and contains a link to the claims sign in url" do
        expect(invite_email.to).to contain_exactly(user.email)
        expect(invite_email.subject).to eq("Invitation to join Claim funding for mentor training")
        expect(invite_email.body).to have_content <<~EMAIL
          Dear John,

          You have been invited to join the Claim funding for mentor training service

          # Sign in to the support site

          If you have a DfE Sign-in account, you can use it to sign in:

          http://claims.localhost:3000/sign-in

          If you need to create a DfE Sign-in account, you can do this after clicking "Sign in using DfE Sign-in"

          After creating a DfE Sign-in account, you will need to return to this email and [sign in to access the service](http://claims.localhost:3000/sign-in).

          # Give feedback or report a problem

          If you have any questions or feedback, please [contact the service team on Slack](https://ukgovernmentdfe.slack.com/archives/C0657JE64HX)

          Regards

          Claim funding for mentor training team
        EMAIL
      end
    end

    context "when inviting a user to the placements service" do
      subject(:invite_email) { described_class.with(service: "placements").support_user_invitation(user) }

      let(:user) { create(:placements_support_user, first_name: "John", last_name: "Doe") }

      it "is addressed to the user's email and contains a link to the placements sign in url" do
        expect(invite_email.to).to contain_exactly(user.email)
        expect(invite_email.subject).to eq("Invitation to join Claim funding for mentor training")
        expect(invite_email.body).to have_content <<~EMAIL
          Dear John,

          You have been invited to join the Claim funding for mentor training service

          # Sign in to the support site

          If you have a DfE Sign-in account, you can use it to sign in:

          http://placements.localhost:3000/sign-in

          If you need to create a DfE Sign-in account, you can do this after clicking "Sign in using DfE Sign-in"

          After creating a DfE Sign-in account, you will need to return to this email and [sign in to access the service](http://placements.localhost:3000/sign-in).

          # Give feedback or report a problem

          If you have any questions or feedback, please [contact the service team on Slack](https://ukgovernmentdfe.slack.com/archives/C0657JE64HX)

          Regards

          Claim funding for mentor training team
        EMAIL
      end
    end
  end

  describe "#support_user_removal_notification" do
    context "when removing a user from the claims service" do
      subject(:removal_email) { described_class.with(service: "claims").support_user_removal_notification(user) }

      let(:user) { create(:claims_support_user, first_name: "John", last_name: "Doe") }

      it "is addressed to the user's email and contains a link to the claims sign in url" do
        expect(removal_email.to).to contain_exactly(user.email)
        expect(removal_email.subject).to eq("You have been removed from Claim funding for mentor training")
        expect(removal_email.body).to have_content <<~EMAIL
          Dear John,

          You have been removed from the Claim funding for mentor training service.

          If you think this was a mistake, [contact the service team on Slack](https://ukgovernmentdfe.slack.com/archives/C0657JE64HX).

          Regards

          Claim funding for mentor training team
        EMAIL
      end
    end

    context "when removing a user from the placements service" do
      subject(:removal_email) { described_class.with(service: "placements").support_user_removal_notification(user) }

      let(:user) { create(:placements_support_user, first_name: "John", last_name: "Doe") }

      it "is addressed to the user's email and contains a link to the placements sign in url" do
        expect(removal_email.to).to contain_exactly(user.email)
        expect(removal_email.subject).to eq("You have been removed from Claim funding for mentor training")
        expect(removal_email.body).to have_content <<~EMAIL
          Dear John,

          You have been removed from the Claim funding for mentor training service.

          If you think this was a mistake, [contact the service team on Slack](https://ukgovernmentdfe.slack.com/archives/C0657JE64HX).

          Regards

          Claim funding for mentor training team
        EMAIL
      end
    end
  end
end
