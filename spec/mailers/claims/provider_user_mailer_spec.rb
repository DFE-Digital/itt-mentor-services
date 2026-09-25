require "rails_helper"

RSpec.describe Claims::ProviderUserMailer, type: :mailer do
  describe "#user_membership_created_notification" do
    subject(:invite_email) { described_class.user_membership_created_notification(user, organisation) }

    let(:user) { create(:claims_provider_user, first_name: "Joe") }
    let(:organisation) { create(:claims_provider, name: "Best Practice Network") }

    it "sends the invitation" do
      expect(invite_email.to).to contain_exactly(user.email)
      expect(invite_email.subject).to eq("Invitation to join Claim funding for mentor training")
      expect(invite_email.body).to have_content <<~EMAIL
        Dear Joe,

        You have been invited to join the Claim funding for mentor training service for Best Practice Network.

        Sign in using DfE Sign-in:

        [http://claims.localhost/sign-in?utm_campaign=provider&utm_medium=notification&utm_source=email](http://claims.localhost/sign-in?utm_campaign=provider&utm_medium=notification&utm_source=email)

        # Give feedback or report a problem

        If you have any questions or feedback, please contact the team at [ittmentor.funding@education.gov.uk](mailto:ittmentor.funding@education.gov.uk).

        Regards

        Claim funding for mentor training team
      EMAIL
    end
  end

  describe "#user_membership_destroyed_notification" do
    subject(:removal_email) { described_class.user_membership_destroyed_notification(user, organisation) }

    let(:user) { create(:claims_provider_user, first_name: "Joe") }
    let(:organisation) { create(:claims_provider, name: "Best Practice Network") }

    it "sends the removal notification" do
      expect(removal_email.to).to contain_exactly(user.email)
      expect(removal_email.subject).to eq("You have been removed from Claim funding for mentor training")
      expect(removal_email.body).to have_content <<~EMAIL
        Dear Joe,

        You have been removed from the Claim funding for mentor training service for Best Practice Network.

        # Give feedback or report a problem

        If you have any questions or feedback, please contact the team at [ittmentor.funding@education.gov.uk](mailto:ittmentor.funding@education.gov.uk).

        Regards

        Claim funding for mentor training team
      EMAIL
    end
  end
end
