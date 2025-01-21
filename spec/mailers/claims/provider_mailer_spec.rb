require "rails_helper"

RSpec.describe Claims::ProviderMailer, type: :mailer do
  describe "#sampling_checks_required" do
    subject(:sampling_checks_required_email) { described_class.sampling_checks_required(provider_sampling) }

    let(:provider) { create(:claims_provider) }
    let(:provider_sampling) { create(:provider_sampling, provider:) }
    let(:url_for_csv) { "https://example.com" }
    let(:service_name) { "Claim funding for mentor training" }
    let(:support_email) { "ittmentor.funding@education.gov.uk" }
    let(:completion_date) { 30.days.from_now.strftime("%d %B %Y") }
    let(:service_url) { claims_root_url }

    before do
      allow(Rails.application.message_verifier(:sampling)).to receive(:generate).and_return("token")
    end

    it "sends the sampling checks required email" do
      expect(sampling_checks_required_email.to).to match_array(provider.email_addresses)
      expect(sampling_checks_required_email.subject).to eq("ITT mentor claims need to be quality assured")
      expect(sampling_checks_required_email.body.to_s.squish).to eq(<<~EMAIL.squish)
        #{provider.name},

        You are required by Department for Education (DfE) to complete quality assurance on funding claims associated with #{provider.name}.

        One or more schools submitted funding requests to DfE due to you providing training for their staff to become initial teacher training (ITT) mentors.

        # You must complete quality assurance by #{completion_date}

        If you do not check these claims by midnight #{completion_date}, we may escalate the assurance process. This can include removing funding from schools you worked with.

        ------------

        # What you need to do

        Use the CSV file to check the accuracy of the claims associated with you and record your answers in the file. It is in a spreadsheet format for you to fill out.

        [http://claims.localhost/sampling/claims?token=token](http://claims.localhost/sampling/claims?token=token)

        This link will expire in 7 days due to data security. To request a new link, reply to this email.

        To complete the CSV, you must:

          - fill in ‘yes’ or no’ in the ‘claim_accepted’ column
          - for any ‘no’ answers, give us a reason for rejection validated by the school in the ‘rejection_reason’ column
          - reply to this email and attach the updated file by #{completion_date}

        ## If the claims are accurate
        If the mentors, hours and number of claims are correct, mark the claims as ‘yes’ in the ‘claim_accepted’ column of the CSV file.

        ## If you disagree with a claim
        If you disagree with the information a school submitted to us, contact the school to discuss it. They may have additional evidence or a reason.

        ## If the school gives you valid evidence after speaking to them
        If you accept the evidence the placement school provides, mark the claim as ‘yes’ in the ‘claim_accepted’ column.

        ## If the school does not give you valid evidence after speaking to them
        If the school cannot provide any additional information or cannot provide information that you accept, mark the claim as ‘no’ in the ‘claim_accepted’ column.

        You must give a reason why a claim is incorrect. Write this in the ‘rejection_reason’ column.

        Some reasons may include that a mentor is:

          - on the Early Career Framework (ECF), rather than ITT
          - claiming too many hours
          - claiming too few hours
          - not known to you
          - not employed at the school

        --------

        ## After you complete quality assurance

        For any rejected claims, we will contact schools to confirm they agree. Make sure you speak to the school about rejected claims before you submit your answers to us. This will avoid any confusion about their eligibility for funding.

        --------

        ## Contact us

        If you need any help with completing the quality assurance, contact the team at [#{support_email}](mailto:#{support_email})

        Learn more about [funding for mentor training on GOV.UK](http://claims.localhost/)


        Claim funding for mentor training team
      EMAIL
    end
  end
end
