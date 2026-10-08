require "rails_helper"

RSpec.describe Claims::ProviderMailer, type: :mailer do
  let(:provider) { create(:claims_provider) }
  let(:provider_sampling) { create(:provider_sampling, provider:) }
  let(:provider_user) { create(:claims_provider_user, providers: [provider]) }
  let(:url_for_csv) { "https://example.com" }
  let(:service_name) { "Claim funding for mentor training" }
  let(:support_email) { "ittmentor.funding@education.gov.uk" }
  let(:service_url) { claims_root_url }
  let(:download_access_token_double) { instance_double(Claims::DownloadAccessToken) }

  before do
    allow(Claims::DownloadAccessToken).to receive(:create!).and_return(download_access_token_double)
    allow(download_access_token_double).to receive(:generate_token_for).with(:csv_download).and_return("token")
  end

  describe "#sampling_checks_required" do
    subject(:sampling_checks_required_email) { described_class.sampling_checks_required(provider_sampling, provider_user) }

    let(:number_of_claims) { "2 claims" }
    let(:expected_body) do
      <<~EMAIL
        #{provider.name},

        You are required by the Department for Education (DfE) to audit #{number_of_claims} for initial teacher training (ITT) general mentor funding associated with #{provider.name}.

        One or more schools submitted funding requests to DfE due to you providing training for their staff to become ITT mentors.

        # You must audit claims by #{completion_date}

        If you do not audit these claims by 11:59pm on #{completion_date}, we may escalate the audit process. This can include removing funding from schools you worked with.

        ------------

        # What you need to do

        You have been added to the Claim funding for mentor training service to audit claims. If you are not the right person in your organisation, please:

        - access the service using DfE sign-in and add an appropriate colleague in the Users section
        - forward this email to the appropriate colleague after adding them as a user

        Sign in to the Claim service using your DfE sign-in account. Review the claims selected for audit, then select each claim and follow the steps on the page.

        - If the claims are accurate, select the ‘Approve’ button.
        - If one or more claims are not accurate, select the ‘Amend’ button and, when prompted, provide the reason why the claim is not accurate.

        Some reasons for amending a claim may include that a mentor is:

        - an Early Career Teacher Entitlement mentor, rather than ITT
        - claiming too many hours
        - not known to you
        - not employed at the school

        --------

        ## After you complete the audit

        If you have amended any claims, schools will receive a notification of this change. Schools will then have 30 days to respond to the audit.

        Make sure you speak to the school about any amended claims before you submit them on the service. This will avoid any confusion about their eligibility for funding.

        --------

        ## Contact us

        If you need any help with signing in to the service, or completing the audit, contact the team at [#{support_email}](mailto:#{support_email})

        Learn more about [funding for mentor training on GOV.UK](http://claims.localhost/?utm_campaign=provider&utm_medium=notification&utm_source=email)

        Claim funding for mentor training team
      EMAIL
    end

    before do
      Timecop.freeze(Time.zone.parse("#{current_date} 00:00"))
      create_list(:claims_provider_sampling_claim, 2, provider_sampling:)
    end

    after do
      Timecop.return
    end

    context "when the completion date is a weekday" do
      let(:current_date) { "20/01/2025" }
      let(:completion_date) { "19 February 2025" }

      it "sends the sampling checks required email" do
        expect(sampling_checks_required_email.to).to contain_exactly(provider_user.email)
        expect(sampling_checks_required_email.subject).to eq("ITT mentor claims need to be audited")
        expect(sampling_checks_required_email.body.to_s.squish).to eq(expected_body.squish)
      end
    end

    context "when the completion date is a weekend" do
      let(:current_date) { "24/01/2025" }
      let(:completion_date) { "24 February 2025" }

      it "sends the sampling checks required email with the next weekday as the completion date" do
        expect(sampling_checks_required_email.body.to_s.squish).to eq(expected_body.squish)
      end
    end

    context "when the provider has a single claim to audit" do
      let(:current_date) { "20/01/2025" }
      let(:completion_date) { "19 February 2025" }
      let(:number_of_claims) { "1 claim" }

      before { provider_sampling.provider_sampling_claims.last.destroy! }

      it "uses the singular form of claim" do
        expect(sampling_checks_required_email.body.to_s.squish).to eq(expected_body.squish)
      end
    end
  end

  describe "#resend_sampling_checks_required" do
    subject(:resend_sampling_checks_required_email) { described_class.resend_sampling_checks_required(provider_sampling, provider_user) }

    let(:number_of_claims) { "2 claims" }
    let(:completion_date) { "19 February 2025" }
    let(:expected_body) do
      <<~EMAIL
        #{provider.name},

        This is a reminder that you still have #{number_of_claims} for initial teacher training (ITT) general mentor funding waiting to be audited.

        # You must audit claims by #{completion_date}

        If you do not audit these claims by 11:59pm on #{completion_date}, we may escalate the audit process. This can include removing funding from schools you worked with.

        ------------

        # What you need to do

        Sign in to the Claim funding for mentor training service using your DfE sign-in account. Review the claims selected for audit, then select each claim and follow the steps on the page.

        [http://claims.localhost/?utm_campaign=provider&utm_medium=notification&utm_source=email](http://claims.localhost/?utm_campaign=provider&utm_medium=notification&utm_source=email)

        - If the claims are accurate, select the ‘Approve’ button.
        - If one or more claims are not accurate, select the ‘Amend’ button and, when prompted, provide the reason why the claim is not accurate.

        If you are not the right person in your organisation to audit these claims, please:

        - access the service using DfE sign-in and add an appropriate colleague in the Users section
        - forward this email to the appropriate colleague after adding them as a user

        --------

        ## Contact us

        If you need any help with signing in to the service, or completing the audit, contact the team at [#{support_email}](mailto:#{support_email})

        You will receive this reminder every Monday until all of your claims have been audited.

        Claim funding for mentor training team
      EMAIL
    end

    before do
      Timecop.freeze(Time.zone.parse("20/01/2025 00:00"))
      create_list(:claim, 2, status: :sampling_in_progress, provider:).each do |claim|
        create(:claims_provider_sampling_claim, claim:, provider_sampling:)
      end
      create(:claims_provider_sampling_claim, provider_sampling:, claim: create(:claim, :submitted, provider:))
    end

    after { Timecop.return }

    it "sends the audit reminder email" do
      expect(resend_sampling_checks_required_email.to).to contain_exactly(provider_user.email)
      expect(resend_sampling_checks_required_email.subject).to eq("Deadline #{completion_date}: ITT mentor claims are waiting to be audited")
      expect(resend_sampling_checks_required_email.body.to_s.squish).to eq(expected_body.squish)
    end

    context "when the provider has a single outstanding claim" do
      let(:number_of_claims) { "1 claim" }

      before { provider_sampling.provider_sampling_claims.find_by!(claim: provider_sampling.claims.sampling_in_progress.first).destroy! }

      it "uses the singular form of claim" do
        expect(resend_sampling_checks_required_email.body.to_s.squish).to eq(expected_body.squish)
      end
    end
  end
end
