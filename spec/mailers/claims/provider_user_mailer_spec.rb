require "rails_helper"

RSpec.describe Claims::ProviderUserMailer, type: :mailer do
  describe "#user_membership_created_notification" do
    subject(:invite_email) { described_class.user_membership_created_notification(user, organisation) }

    let(:user) { create(:claims_provider_user, first_name: "Joe") }
    let(:organisation) { create(:claims_provider, name: "Best Practice Network") }

    it "sends the invitation" do
      expect(invite_email.to).to contain_exactly(user.email)
      expect(invite_email.subject).to eq("Claim funding for mentor training: you have been added to the service")
      expect(invite_email.body).to have_content <<~EMAIL
        You have been added to the Claim funding for mentor training service on behalf of Best Practice Network.

        The Department for Education is preparing to audit claims for Initial Teacher Training (ITT) general mentor funding.

        If claims from placement schools associated with your organisation are selected for audit, you will be able to audit claims directly on the service.

        ## You do not need to do anything yet

        Claims relating to your organisation may or may not be selected for audit. We will contact you with more information if you are selected for audit.

        ## If you are not the right person to audit claims

        If you are not the right person in your organisation to audit claims for ITT general mentor funding, please:

        * access the [service](http://claims.localhost/sign-in?utm_campaign=provider&utm_medium=notification&utm_source=email) using DfE Sign-in and add an appropriate colleague in the Users section
        * new users will receive relevant communications from the service after they have been onboarded

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
