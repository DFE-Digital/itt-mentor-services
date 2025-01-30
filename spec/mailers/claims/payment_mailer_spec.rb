require "rails_helper"

RSpec.describe Claims::PaymentMailer, freeze: "20 December 2024", type: :mailer do
  let(:payment) { create(:claims_payment) }
  let(:download_page_url) { claims_payments_claims_url(token:, host: "claims.localhost") }
  let(:token) { Rails.application.message_verifier(:payments).generate(payment.id, expires_in: 7.days) }

  describe "#payment_created_notification" do
    subject(:email) { described_class.payment_created_notification(payment) }

    it "sends the sampling checks required email" do
      expect(email.to).to contain_exactly("esfa@example.com")
      expect(email.subject).to eq("Claims ready for payment - Claim funding for mentor training")
      expect(email.body.to_s.squish).to eq(<<~EMAIL.squish)
        To the payer,

        These claims from the Claim funding for mentor training service (Claim) are ready for payment — the link to the latest CSV file is valid for 7 days:

        [#{download_page_url}](#{download_page_url})

        What you need to do:

        1. Check and validate the claims in the CSV file by marking them as ‘paid’ or ‘unpaid’ in the ‘claim_status’ column.

        2. If you mark a claim as ‘unpaid’, add the reason in the ‘claim_unpaid_reason’ column.

        3. Reply to this email and attach the updated CSV file.

        The Claim Support team will follow up on the reasons for unpaid claims and email back an updated version.

        If you have a problem opening the link or it has expired, reply to this email and request that it be sent again.

        # Give feedback or report a problem

        If you have any questions or feedback, please contact the team at [ittmentor.funding@education.gov.uk](ittmentor.funding@education.gov.uk).

        Regards
        Claim funding for mentor training team
      EMAIL
    end
  end

  describe "#resend_payment_created_notification" do
    subject(:email) { described_class.resend_payment_created_notification(payment) }

    it "sends the sampling checks required email" do
      expect(email.to).to contain_exactly("esfa@example.com")
      expect(email.subject).to eq("Claims ready for payment - Claim funding for mentor training")
      expect(email.body.to_s.squish).to eq(<<~EMAIL.squish)
        To the payer,

        ^ We are resending this email as requested. Please disregard any previous emails you may have received.

        These claims from the Claim funding for mentor training service (Claim) are ready for payment — the link to the latest CSV file is valid for 7 days:

        [#{download_page_url}](#{download_page_url})

        What you need to do:

        1. Check and validate the claims in the CSV file by marking them as ‘paid’ or ‘unpaid’ in the ‘claim_status’ column.

        2. If you mark a claim as ‘unpaid’, add the reason in the ‘claim_unpaid_reason’ column.

        3. Reply to this email and attach the updated CSV file.

        The Claim Support team will follow up on the reasons for unpaid claims and email back an updated version.

        If you have a problem opening the link or it has expired, reply to this email and request that it be sent again.

        # Give feedback or report a problem

        If you have any questions or feedback, please contact the team at [ittmentor.funding@education.gov.uk](ittmentor.funding@education.gov.uk).

        Regards
        Claim funding for mentor training team
      EMAIL
    end
  end
end
