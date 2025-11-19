require "rails_helper"

RSpec.describe Claims::ProviderMailer, type: :mailer do
  let(:provider) { create(:claims_provider) }
  let(:provider_sampling) { create(:provider_sampling, provider:) }
  let(:url_for_csv) { "https://example.com" }
  let(:service_name) { "Claim funding for mentor training" }
  let(:support_email) { "ittmentor.funding@education.gov.uk" }
  let(:service_url) { claims_root_url }
  let(:completion_date) { "10 February 2025" }
  let(:download_access_token_double) { instance_double(Claims::DownloadAccessToken) }

  before do
    allow(Claims::DownloadAccessToken).to receive(:create!).and_return(download_access_token_double)
    allow(download_access_token_double).to receive(:generate_token_for).with(:csv_download).and_return("token")
  end

  describe "#sampling_checks_required" do
    subject(:sampling_checks_required_email) { described_class.sampling_checks_required(provider_sampling, email_address: provider.primary_email_address) }

    context "when the completion date is a weekday" do
      let(:current_date) { "20/01/2025" }

      before do
        Timecop.freeze(Time.zone.parse("#{current_date} 00:00"))
      end

      after do
        Timecop.return
      end

      it "sends the sampling checks required email" do
        expect(sampling_checks_required_email.to).to match_array(provider.primary_email_address)
        expect(sampling_checks_required_email.subject).to eq("ITT mentor claims need to be quality assured")
        expect(sampling_checks_required_email.body.to_s.squish).to eq(<<~EMAIL.squish)
          #{provider.name},

          You are required by Department for Education (DfE) to complete quality assurance on funding claims associated with #{provider.name}.

          One or more schools submitted funding requests to DfE due to you providing training for their staff to become initial teacher training (ITT) mentors.

          # You must complete quality assurance by #{completion_date}

          If you do not check these claims by 11:59pm on #{completion_date}, we may escalate the assurance process. This can include removing funding from schools you worked with.

          ------------

          # What you need to do

          Use the CSV file to check the accuracy of the claims associated with you and record your answers in the file. It is in a spreadsheet format for you to fill out.#{"  "}

          Visit the GOV.UK claim funding for mentor training website to download the file:

          [http://claims.localhost/sampling/claims?token=token&utm_campaign=provider&utm_medium=notification&utm_source=email](http://claims.localhost/sampling/claims?token=token&utm_campaign=provider&utm_medium=notification&utm_source=email)

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

          Learn more about [funding for mentor training on GOV.UK](http://claims.localhost/?utm_campaign=provider&utm_medium=notification&utm_source=email)


          Claim funding for mentor training team
        EMAIL
      end
    end

    context "when the completion date is a weekend" do
      let(:current_date) { "18/01/2025" }

      before do
        Timecop.freeze(Time.zone.parse("#{current_date} 00:00"))
      end

      after do
        Timecop.return
      end

      it "sends the sampling checks required email" do
        expect(sampling_checks_required_email.to).to match_array(provider.primary_email_address)
        expect(sampling_checks_required_email.subject).to eq("ITT mentor claims need to be quality assured")
        expect(sampling_checks_required_email.body.to_s.squish).to eq(<<~EMAIL.squish)
          #{provider.name},

          You are required by Department for Education (DfE) to complete quality assurance on funding claims associated with #{provider.name}.

          One or more schools submitted funding requests to DfE due to you providing training for their staff to become initial teacher training (ITT) mentors.

          # You must complete quality assurance by #{completion_date}

          If you do not check these claims by 11:59pm on #{completion_date}, we may escalate the assurance process. This can include removing funding from schools you worked with.

          ------------

          # What you need to do

          Use the CSV file to check the accuracy of the claims associated with you and record your answers in the file. It is in a spreadsheet format for you to fill out.#{"  "}

          Visit the GOV.UK claim funding for mentor training website to download the file:

          [http://claims.localhost/sampling/claims?token=token&utm_campaign=provider&utm_medium=notification&utm_source=email](http://claims.localhost/sampling/claims?token=token&utm_campaign=provider&utm_medium=notification&utm_source=email)

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

          Learn more about [funding for mentor training on GOV.UK](http://claims.localhost/?utm_campaign=provider&utm_medium=notification&utm_source=email)


          Claim funding for mentor training team
        EMAIL
      end
    end
  end

  describe "#resend_sampling_checks_required" do
    subject(:resend_sampling_checks_required_email) { described_class.resend_sampling_checks_required(provider.primary_email_address, provider_sampling) }

    context "when the completion date is a weekday" do
      let(:current_date) { "20/01/2025" }

      before do
        Timecop.freeze(Time.zone.parse("#{current_date} 00:00"))
      end

      after do
        Timecop.return
      end

      it "resends the sampling checks required email" do
        expect(resend_sampling_checks_required_email.to).to match_array(provider.primary_email_address)
        expect(resend_sampling_checks_required_email.subject).to eq("ITT mentor claims need to be quality assured")
        expect(resend_sampling_checks_required_email.body.to_s.squish).to eq(<<~EMAIL.squish)
          #{provider.name},

          ^ We are resending this email as requested. Please disregard any previous emails you may have received.

          You are required by Department for Education (DfE) to complete quality assurance on funding claims associated with #{provider.name}.

          One or more schools submitted funding requests to DfE due to you providing training for their staff to become initial teacher training (ITT) mentors.

          # You must complete quality assurance by #{completion_date}

          If you do not check these claims by 11:59pm on #{completion_date}, we may escalate the assurance process. This can include removing funding from schools you worked with.

          ------------

          # What you need to do

          Use the CSV file to check the accuracy of the claims associated with you and record your answers in the file. It is in a spreadsheet format for you to fill out.#{"  "}

          Visit the GOV.UK claim funding for mentor training website to download the file:

          [http://claims.localhost/sampling/claims?token=token&utm_campaign=provider&utm_medium=notification&utm_source=email](http://claims.localhost/sampling/claims?token=token&utm_campaign=provider&utm_medium=notification&utm_source=email)

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

          Learn more about [funding for mentor training on GOV.UK](http://claims.localhost/?utm_campaign=provider&utm_medium=notification&utm_source=email)


          Claim funding for mentor training team
        EMAIL
      end
    end

    context "when the completion date is a weekend" do
      let(:current_date) { "18/01/2025" }

      before do
        Timecop.freeze(Time.zone.parse("#{current_date} 00:00"))
      end

      after do
        Timecop.return
      end

      it "resends the sampling checks required email" do
        expect(resend_sampling_checks_required_email.to).to match_array(provider.primary_email_address)
        expect(resend_sampling_checks_required_email.subject).to eq("ITT mentor claims need to be quality assured")
        expect(resend_sampling_checks_required_email.body.to_s.squish).to eq(<<~EMAIL.squish)
          #{provider.name},

          ^ We are resending this email as requested. Please disregard any previous emails you may have received.

          You are required by Department for Education (DfE) to complete quality assurance on funding claims associated with #{provider.name}.

          One or more schools submitted funding requests to DfE due to you providing training for their staff to become initial teacher training (ITT) mentors.

          # You must complete quality assurance by #{completion_date}

          If you do not check these claims by 11:59pm on #{completion_date}, we may escalate the assurance process. This can include removing funding from schools you worked with.

          ------------

          # What you need to do

          Use the CSV file to check the accuracy of the claims associated with you and record your answers in the file. It is in a spreadsheet format for you to fill out.#{"  "}

          Visit the GOV.UK claim funding for mentor training website to download the file:

          [http://claims.localhost/sampling/claims?token=token&utm_campaign=provider&utm_medium=notification&utm_source=email](http://claims.localhost/sampling/claims?token=token&utm_campaign=provider&utm_medium=notification&utm_source=email)

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

          Learn more about [funding for mentor training on GOV.UK](http://claims.localhost/?utm_campaign=provider&utm_medium=notification&utm_source=email)


          Claim funding for mentor training team
        EMAIL
      end
    end
  end

  describe "#claims_have_not_been_submitted" do
    subject(:claims_have_not_been_submitted_email) do
      described_class.claims_have_not_been_submitted(
        create(:provider_email_address, provider:, email_address:),
      )
    end

    let(:provider_name) { "Aes Sedai Trust" }
    let(:email_address) { "admin@aes-sedai-trust.com" }
    let(:provider) { create(:claims_provider, name: provider_name) }
    let!(:claim_window) { create(:claim_window, :current) }
    let(:academic_year_name) { claim_window.academic_year_name }

    it "sends the claims have not been submitted email" do
      expect(claims_have_not_been_submitted_email.to).to contain_exactly(email_address)
      expect(claims_have_not_been_submitted_email.subject).to eq("Deadline #{I18n.l(claim_window.ends_on, format: :long)}: your schools haven’t claimed for ITT mentor funding")
      expect(claims_have_not_been_submitted_email.body.to_s.squish).to eq(<<~EMAIL.squish)
        Dear Aes Sedai Trust,

        The Claim Funding for ITT Mentoring Training digital service launched in April 2025.

        Your placement schools are eligible to claim funding for the time their ITT mentors spent in training this academic year.

        However, no claims are currently associated with you as an accredited provider, which means your schools may be missing out on funding they’re entitled to.

        ## What You Need to Do

        To help your schools claim their funding:

        1. Add all your placement schools for this academic year to the Register trainee teacher service.
        2. Contact your placement schools to advise them to submit their claims via the new service.

        ## Claim Deadline

        The deadline for schools to submit claims for the #{academic_year_name} is #{I18n.l(claim_window.ends_on, format: :long)}.

        ## Guidance for Schools

        ## How to Access the Service

        1. Check for an onboarding email from DfE.
        2. If not received, ask the school’s DfE Sign-in approver to check and add users.
        3. If no one has received it, confirm with the accredited provider that the school is on the Register trainee teacher service.
        4. For help, contact: [#{support_email}](mailto:#{support_email})

        ### How to Make a Claim

        - Sign in using a DfE Sign-in account\*
        - Claim for ITT general mentors only (for ECT mentors, [follow this guidance](https://www.gov.uk/guidance/funding-and-eligibility-for-ecf-based-training))
        - Ensure the mentor’s name matches the Teacher Register (update via [Access Teaching Qualifications](https://www.gov.uk/guidance/access-your-teaching-qualifications) if needed)\*\*

        \\* DfE Sign-in now uses multi-factor authentication. Users may need to create a new account with a secure password.
        \\*\\* To update a mentor’s name, submit a change via Access Teaching Qualifications.

        For more information, see [additional guidance](https://assets.publishing.service.gov.uk/media/67448404e26d6f8ca3cb358d/General_mentor_training_-_additional_guidance.pdf) or contact: [#{support_email}](mailto:#{support_email}).

        Kind regards

        #{service_name} team
      EMAIL
    end
  end
end
