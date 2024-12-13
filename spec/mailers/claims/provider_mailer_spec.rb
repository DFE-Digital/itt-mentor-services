require "rails_helper"

RSpec.describe Claims::ProviderMailer, type: :mailer do
  describe "#sampling_checks_required" do
    subject(:sampling_checks_required_email) { described_class.sampling_checks_required(provider, url_for_csv) }

    let(:provider) { create(:claims_provider, email_address: "aes_sedai_trust@example.com") }
    let(:url_for_csv) { "https://example.com" }
    let(:service_name) { "Claim funding for mentor training" }
    let(:support_email) { "ittmentor.funding@education.gov.uk" }

    it "sends the sampling checks required email" do
      expect(sampling_checks_required_email.to).to contain_exactly(provider.email_address)
      expect(sampling_checks_required_email.subject).to eq("ITT mentor claims need to be assured")
      expect(sampling_checks_required_email.body.to_s.squish).to eq(<<~EMAIL.squish)
        Dear #{provider.name},

        These claims from the Claim funding for mentor training service (Claim) are ready for post-payment assurance. The link to the latest CSV file is valid for 7 days.

        #{url_for_csv}

        What you need to do:

        1. Check the information detailed in the claims matches your information, specifically the mentor names and the hours of training. If it does, mark them as ‘yes’ in the ‘claim_assured’ column.

        2. If you disagree with the information, please contact the placement school to discuss it. They may have additional evidence.

        3. If they cannot provide any additional information or cannot provide information that you are not content with, mark the claim as ‘no’ in the ‘claim_assured’ column. In the ‘claim_not_assured_reason’ column, indicate why the claim has not been assured. For example, the mentor’s name is wrong, or the number of hours exceeds the evidence that you have.

        4. If the placement school provides any additional information you are content with, mark the claim as ‘yes’ in the ‘claim_assured’ column.

        5. Reply to this email and attach the updated CSV.

        The Claim Support team will follow up with the placement schools on the claims that have not been assured. You will not need to take further action.

        If you have a problem opening the link or it has expired, reply to this email and request that it be sent again.

        # Give feedback or report a problem
        If you have any questions or feedback, please contact the team at [#{support_email}](mailto:#{support_email}).

        Regards
        #{service_name} team
      EMAIL
    end
  end
end
