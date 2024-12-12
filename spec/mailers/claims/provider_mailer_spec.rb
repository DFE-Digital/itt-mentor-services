require "rails_helper"

RSpec.describe Claims::ProviderMailer, type: :mailer do
  describe "#sampling_checks_required" do
    subject(:sampling_checks_required_email) { described_class.sampling_checks_required(provider, url_for_csv) }

    let(:provider) { create(:claims_provider, email_address: "aes_sedai_trust@example.com") }
    let(:url_for_csv) { "https://example.com" }

    it "sends the sampling checks required email" do
      expect(sampling_checks_required_email.to).to contain_exactly(provider.email_address)
      expect(sampling_checks_required_email.subject).to eq("Checks needed – Claim funding for mentor training service")
      expect(sampling_checks_required_email.body.to_s.squish).to eq(<<~EMAIL.squish)
        To #{provider.name},

        As part of the Claim funding for mentor training (Claim) service assurance, we have sent you a sample of claims to confirm they are correct and approved — the link to the CSV file is valid for 7 days:

        #{url_for_csv}

        # What you need to check

        You need to check the claim details match your own records and are correct. You should check BOTH:

        - training hours that have been claimed
        - mentors' names

        # If all claims are correct

        If the mentors’ names and training hours are all correct, mark them as ‘approved’ in the CSV file and email back the updated file.

        # If any claims are incorrect

        If any of the training hours or mentor names are incorrect you need to:

        1. contact the placement school to agree changes to claim details
        2. add an explanation of agreed changes in the ‘claim_change_reason’ column of the CSV file. For example, incorrect claim amount: claim should be for 8 not 10 hours
        3. mark the claim as ‘not approved’ and email back the updated file
        4. the Claim Support team will update the details in the system and process any payment adjustments

        # If you and the placement schools do not agree on changes to a claim

        If the placement schools do not agree with you about changes to claim details, you need to:

        1. add an explanation in the ‘claim_change_reason’ column of the CSV file. For example, School training hours different – evidence not provided
        2. mark the claim as ‘information needed’ and email back the updated file
        3. the Claim Support team will contact the placement school and aim to resolve issues

        # What to do if the link does not work

        The link in this email is valid for 7 days. If you have a problem opening the link, or it has expired, reply to this email and ask for the link to be sent again.

        # When is the deadline to complete the checks

        Please complete your checks and email back an updated file within 30 days.

        Regards,

        Claim funding for mentor training team
      EMAIL
    end
  end
end
