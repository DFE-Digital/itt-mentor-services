require "rails_helper"

RSpec.describe Claims::ESFAMailer, type: :mailer do
  describe "#claims_require_clawback" do
    subject(:claims_require_clawback_email) { described_class.claims_require_clawback(clawback) }

    let(:clawback) { create(:claims_clawback) }
    let(:url_for_csv) { claims_clawback_claims_url(token:, host: "claims.localhost") }
    let(:token) { Rails.application.message_verifier(:clawback).generate(clawback.id, expires_in: 7.days) }
    let(:esfa_emails) { %w[example1@education.gov.uk example2@education.gov.uk] }
    let(:service_name) { "Claim funding for mentor training" }
    let(:support_email) { "ittmentor.funding@education.gov.uk" }

    before do
      allow(Rails.application.message_verifier(:clawback)).to receive(:generate).and_return("token")
    end

    it "sends the claims require clawback email" do
      ClimateControl.modify CLAIMS_ESFA_EMAIL_ADDRESSES: esfa_emails.join(",") do
        expect(claims_require_clawback_email.to).to match_array(esfa_emails)
        expect(claims_require_clawback_email.subject).to eq("Claims requiring clawback - Claim funding for mentor training")
        expect(claims_require_clawback_email.body.to_s.squish).to eq(<<~EMAIL.squish)
          To ESFA,

          The claims in the CSV file link are ready for clawback— the link to the latest CSV file is valid for 7 days:

          #{url_for_csv}

          What you need to do:

          1. Check and validate the claims in the CSV file by marking them as ‘clawback_in_progress’ or ‘clawback_complete’ in the ‘claim_status’ column.

          2. If you mark a claim as ‘clawback_in_progress’, add the reason to the ‘clawback_unsuccessful_reason’ column.

          3. Reply to this email and attach the updated CSV file.

          The Claim Support team will follow up on the reasons for the claims that you could not claw back and email you an updated version.

          If you have a problem opening the link or it has expired, reply to this email and request that it be sent again.

          # Give feedback or report a problem
          If you have any questions or feedback, please contact the team at [#{support_email}](mailto:#{support_email}).

          Regards
          #{service_name} team
        EMAIL
      end
    end
  end
end
