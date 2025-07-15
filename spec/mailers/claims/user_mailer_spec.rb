require "rails_helper"

RSpec.describe Claims::UserMailer, type: :mailer do
  describe "#user_membership_created_notification" do
    subject(:invite_email) { described_class.user_membership_created_notification(user, organisation) }

    let(:user) { create(:claims_user, first_name: "Joe") }
    let(:organisation) { create(:claims_school, name: "Shelbyville Elementary") }
    let!(:claim_window) { create(:claim_window, :current) }

    it "sends the invitation" do
      expect(invite_email.to).to contain_exactly(user.email)
      expect(invite_email.subject).to eq("Invitation to join Claim funding for mentor training")
      expect(invite_email.body).to have_content <<~EMAIL
        Dear Joe,

        You have been invited to join the Claim funding for mentor training service for Shelbyville Elementary because you are a [DfE-sign approver](https://edd-help.signin.education.gov.uk/contact/create-account#:~:text=An%20approver%20is%20someone%20at%20your%20organisation%20responsible,person%2C%20such%20as%20an%20administrator%2C%20manager%2C%20or%20headteacher) for your organisation.

        If you are not the right person in your organisation to submit funding claims for initial teacher training (ITT) general mentor training, please:

        - access the service using DfE sign-in and add an appropriate colleague in the Users section
        - forward this email to the appropriate colleague after adding them as a user

        # Claim funding for mentor training service

        This new DfE service enables schools and education organisations to claim funding for the time spent becoming an ITT general mentor.

        Your organisation has been added to the service because an accredited ITT provider has informed DfE that one or more trainee teachers have undertaken a school placement there during academic year #{claim_window.academic_year_name}.

        # Sign in to submit claims

        Sign in using DfE sign-in:

        [http://claims.localhost/sign-in?utm_campaign=school&utm_medium=notification&utm_source=email](http://claims.localhost/sign-in?utm_campaign=school&utm_medium=notification&utm_source=email)

        If your colleague needs to create a DfE Sign-in account, they can do this after clicking "Sign in using DfE Sign-in"

        After creating a DfE Sign-in account, they will need to return to this email and [sign in to access the service](http://claims.localhost/sign-in?utm_campaign=school&utm_medium=notification&utm_source=email)

        # Prior to submitting claims

        We recommend confirming with your accredited ITT provider the number of hours you are claiming, as they may be asked to provide evidence to support this claim.

        # Give feedback or report a problem

        If you have any questions or feedback, please contact the team at [ittmentor.funding@education.gov.uk](mailto:ittmentor.funding@education.gov.uk).

        Regards

        Claim funding for mentor training team
      EMAIL
    end

    context "when HostingEnvironment.env is 'production'" do
      before do
        allow(HostingEnvironment).to receive(:env).and_return("production")
      end

      it "does not prepend the hosting environment to the subject" do
        expect(invite_email.subject).to eq("Invitation to join Claim funding for mentor training")
      end
    end

    context "when HostingEnvironment.env is 'staging'" do
      before do
        allow(HostingEnvironment).to receive(:env).and_return("staging")
      end

      it "prepends the hosting environment to the subject" do
        expect(invite_email.subject).to eq("[STAGING] Invitation to join Claim funding for mentor training")
      end
    end
  end

  describe "#user_membership_destroyed_notification" do
    subject(:removal_email) { described_class.user_membership_destroyed_notification(user, organisation) }

    let(:user) { create(:claims_user) }
    let(:organisation) { create(:claims_school) }

    it "sends expected message to user" do
      expect(removal_email.to).to contain_exactly user.email
      expect(removal_email.subject).to eq "You have been removed from Claim funding for mentor training"
      expect(removal_email.body).to have_content <<~EMAIL
        Dear #{user.first_name},

        You have been removed from the Claim funding for mentor training service for #{organisation.name}.

        # Give feedback or report a problem

        If you have any questions or feedback, please contact the team at [ittmentor.funding@education.gov.uk](mailto:ittmentor.funding@education.gov.uk).

        Regards

        Claim funding for mentor training team
      EMAIL
    end

    context "when HostingEnvironment.env is 'production'" do
      before do
        allow(HostingEnvironment).to receive(:env).and_return("production")
      end

      it "does not prepend the hosting environment to the subject" do
        expect(removal_email.subject).to eq("You have been removed from Claim funding for mentor training")
      end
    end

    context "when HostingEnvironment.env is 'staging'" do
      before do
        allow(HostingEnvironment).to receive(:env).and_return("staging")
      end

      it "prepends the hosting environment to the subject" do
        expect(removal_email.subject).to eq("[STAGING] You have been removed from Claim funding for mentor training")
      end
    end
  end

  describe "#claim_submitted_notification" do
    subject(:claim_confirmation_email) { described_class.claim_submitted_notification(user, claim) }

    context "when a claim has been submitted" do
      let(:user) { create(:claims_user) }
      let(:school) { create(:claims_school, region: regions(:inner_london)) }
      let(:claim) { create(:claim, reference: "123", school:) }

      it "sends the confirmation email" do
        create(:mentor_training, claim:, hours_completed: 10)

        expect(claim_confirmation_email.to).to contain_exactly(user.email)
        expect(claim_confirmation_email.subject).to eq("Claim submitted for mentor training funding")
        expect(claim_confirmation_email.body.to_s.squish).to eq(<<~EMAIL.squish)
          Dear #{user.first_name},

          You have submitted a claim for mentor training funding on behalf of #{claim.school_name}.

          * Claim reference: #{claim.reference}
          * Claim amount: #{claim.amount.format(symbol: true, decimal_mark: ".", no_cents: false)}
          * Number of mentors: #{claim.mentors.count}
          * Training provider: #{claim.provider_name}

          See your claims on the claim funding for mentor training website:

          http://claims.localhost/schools/#{school.id}/claims/#{claim.id}?utm_campaign=school&utm_medium=notification&utm_source=email

          # Contact us

          If you need any help or have any feedback, contact the team at [ittmentor.funding@education.gov.uk](mailto:ittmentor.funding@education.gov.uk). It may take up to 5 days to receive a response.

          from Claim funding for mentor training at Department for Education
        EMAIL
      end

      context "when HostingEnvironment.env is 'production'" do
        before do
          allow(HostingEnvironment).to receive(:env).and_return("production")
        end

        it "does not prepend the hosting environment to the subject" do
          expect(claim_confirmation_email.subject).to eq("Claim submitted for mentor training funding")
        end
      end

      context "when HostingEnvironment.env is 'staging'" do
        before do
          allow(HostingEnvironment).to receive(:env).and_return("staging")
        end

        it "prepends the hosting environment to the subject" do
          expect(claim_confirmation_email.subject).to eq("[STAGING] Claim submitted for mentor training funding")
        end
      end
    end
  end

  describe "#claim_created_support_notification" do
    subject(:claim_confirmation_email) { described_class.with(service: support_user.service).claim_created_support_notification(claim, user_of_a_school) }

    context "when a claim has been created" do
      let(:support_user) { create(:claims_support_user, :colin) }
      let(:school) { create(:claims_school, region: regions(:inner_london)) }
      let(:claim) { create(:claim, reference: "123", school:) }
      let(:user_of_a_school) { create(:claims_user, email: "babagoli@gmail.com", user_memberships: [build(:user_membership, organisation: school)]) }
      let(:email) { user_of_a_school.email }

      it "sends a notification email to every user for the school" do
        create(:mentor_training, claim:, hours_completed: 10)

        expect(claim_confirmation_email.to).to contain_exactly(email)
        expect(claim_confirmation_email.subject).to eq("New draft claim for mentor training")
        expect(claim_confirmation_email.body.to_s.strip).to eq(<<~EMAIL.strip)
          Dear #{user_of_a_school.first_name},

          We have added a draft claim for mentor training for #{claim.school_name}.
            Your claim reference is #{claim.reference}.

          You can view the claim, edit and submit it on Claim funding for mentor training:

          http://claims.localhost/schools/#{school.id}/claims/#{claim.id}?utm_campaign=school&utm_medium=notification&utm_source=email

          # Give feedback or report a problem

          If you have any questions or feedback, please contact the team at [ittmentor.funding@education.gov.uk](mailto:ittmentor.funding@education.gov.uk).

          Regards

          Claim funding for mentor training team
        EMAIL
      end

      context "when HostingEnvironment.env is 'production'" do
        before do
          allow(HostingEnvironment).to receive(:env).and_return("production")
        end

        it "does not prepend the hosting environment to the subject" do
          expect(claim_confirmation_email.subject).to eq("New draft claim for mentor training")
        end
      end

      context "when HostingEnvironment.env is 'staging'" do
        before do
          allow(HostingEnvironment).to receive(:env).and_return("staging")
        end

        it "prepends the hosting environment to the subject" do
          expect(claim_confirmation_email.subject).to eq("[STAGING] New draft claim for mentor training")
        end
      end
    end
  end

  describe "#claim_requires_clawback" do
    subject(:clawback_email) { described_class.claim_requires_clawback(claim, user) }

    let(:user) { create(:claims_user) }
    let(:school) { build(:claims_school, region: regions(:inner_london)) }
    let(:claim) { build(:claim, reference: "123", school:) }
    let(:mentor_trainings) do
      create_list(:mentor_training,
                  2,
                  :rejected,
                  claim:,
                  hours_completed: 5,
                  hours_clawed_back: 2)
    end

    before { mentor_trainings }

    it "sends the clawback email" do
      expect(clawback_email.to).to contain_exactly(user.email)
      expect(clawback_email.subject).to eq("Your funding for mentor training will be taken back")
      expect(clawback_email.body.to_s.squish).to eq(<<~EMAIL.squish)
        Dear #{user.first_name},

        A claim you made was audited and there was insufficient proof from you that some or all of the claim was valid. Your funding for mentor training will be taken from you and returned to the Department for Education.

        Retrieving this funding is known as clawback.

        Amount being clawed back: £214.40
        Claim reference: 123

        You can view the claim on Claim funding for mentor training:

        http://claims.localhost/schools/#{school.id}/claims/#{claim.id}?utm_campaign=school&utm_medium=notification&utm_source=email

        # What happens next
        The funds will automatically be taken from you.

        For academies, any recovery will be offset in your next available monthly payment. For maintained schools, any recovery will be offset in your local authority’s next available monthly payment and they will recover funding from you via their usual processes.

        Sign in to your account on Claim funding for mentor training to see more details:
        http://claims.localhost/?utm_campaign=school&utm_medium=notification&utm_source=email

        # Contact us
        If you need any help, contact the team at [ittmentor.funding@education.gov.uk](mailto:ittmentor.funding@education.gov.uk). It may take up to 5 days to receive a response.

        Regards
        Claim funding for mentor training team
      EMAIL
    end
  end

  describe "#claims_have_not_been_submitted" do
    subject(:claims_not_submitted_email) { described_class.claims_have_not_been_submitted(user) }

    let(:user) { create(:claims_user, first_name: "Joe") }
    let!(:claim_window) { create(:claim_window, :current) }
    let!(:next_claim_window) { create(:claim_window, :upcoming) }

    it "sends the claims not submitted email" do
      expect(claims_not_submitted_email.to).to contain_exactly(user.email)
      expect(claims_not_submitted_email.subject).to eq("Deadline #{I18n.l(claim_window.ends_on, format: :long)}: Claim Your ITT Mentor Training Funding")
      expect(claims_not_submitted_email.body.to_s.squish).to eq(<<~EMAIL.squish)
        Dear Joe,

        The Claim Funding for ITT Mentoring Training digital service launched in April 2025.

        We believe your school is eligible to claim funding for the time your Initial Teacher Training (ITT) mentors spent in training this academic year.

        If your school has been added to the Register trainee teacher service by your accredited provider, you should have been onboarded and are eligible to claim. However, we’ve not yet received a claim from you.

        ## Eligibility Criteria

        To claim funding, an ITT mentor must have:

        - Completed up to 20 hours of initial mentor training
        - Mentored at least one trainee during the #{claim_window.academic_year_name} academic year

        ## How to access the service

        Check if you’ve received an onboarding email from DfE.

        If not, ask your school’s DfE Sign-in approver if they’ve received it and can add users.

        If no one has received it, confirm with your accredited provider that your school is on the Register trainee teacher service.

        For further help see [additional guidance](https://assets.publishing.service.gov.uk/media/67448404e26d6f8ca3cb358d/General_mentor_training_-_additional_guidance.pdf) or contact: [ittmentor.funding@education.gov.uk](mailto:ittmentor.funding@education.gov.uk).

        ## How to make a claim

        To make a claim, you will need to:

        - Sign in using your DfE Sign-in account*
        - Claim for ITT general mentors only (if you’re claiming for ECT mentors, [follow this guidance](https://www.gov.uk/guidance/funding-and-eligibility-for-ecf-based-training))
        - Ensure the mentor’s name matches the Teacher Register (update names via Access Teaching Qualifications if needed)**

        \\*DfE Sign-in now uses multi-factor authentication. You may need to create a new account with a secure password.
        \\*\\*To update a mentor’s name, submit a change via [Access Teaching Qualifications](https://www.gov.uk/guidance/access-your-teaching-qualifications).

        ## Important

        The deadline to submit claims is #{I18n.l(claim_window.ends_on, format: :long)}. After this date, you will have to wait until the next claim window to opens on #{I18n.l(next_claim_window.starts_on, format: :long)}.

        For more information, see [additional guidance](https://assets.publishing.service.gov.uk/media/67448404e26d6f8ca3cb358d/General_mentor_training_-_additional_guidance.pdf) or email [ittmentor.funding@education.gov.uk](mailto:ittmentor.funding@education.gov.uk).

        Kind regards,

        Claim funding for mentor training team
      EMAIL
    end
  end

  describe "claims_assigned_to_invalid_provider" do
    subject(:claims_assigned_to_invalid_provider_email) { described_class.claims_assigned_to_invalid_provider(user, claims) }

    let(:user) { create(:claims_user, first_name: "Joe") }
    let(:claims) do
      [
        create(:claim, reference: "123", school: school),
        create(:claim, reference: "456", school: school),
        create(:claim, reference: "789", school: school),
      ]
    end
    let(:school) { create(:claims_school, name: "Shelbyville Elementary") }

    it "sends the invalid provider email" do
      expect(claims_assigned_to_invalid_provider_email.to).to contain_exactly(user.email)
      expect(claims_assigned_to_invalid_provider_email.subject).to eq("Action by 25 July: Change your ITT mentor funding claim to ensure it gets paid")
      expect(claims_assigned_to_invalid_provider_email.body.to_s.squish).to eq(<<~EMAIL.squish)
        Dear Joe

        Thank you for submitting a claim through the Claim funding for mentor training service.

        The following claims, submitted by your school, cannot be processed because the ITT provider recorded is not an accredited provider:

        #{claims.pluck(:reference).to_sentence}

        To ensure your claim can be processed and paid, please log-in to the service and record the accredited provider.

        ## What You Need to Do

        To update your accredited provider:

        1. Log in to the Claim funding for mentor training service
        2. Go to the ‘Claims’ tab
        3. Click on a claim with the "Invalid provider" status
        4. Click ‘Change’ next to your current provider selection
        5. Enter your accredited provider's name in the search box
        6. Click ‘Continue’

        ## Deadline: Friday 25 July 2025

        Please update your provider information by this date to avoid delays in payment.

        If you are unsure who the accredited provider is, contact your ITT provider to confirm or review this list: [https://www.gov.uk/government/publications/accredited-initial-teacher-training-itt-providers/list-of-providers-accredited-to-deliver-itt-from-september-2024]([https://www.gov.uk/government/publications/accredited-initial-teacher-training-itt-providers/list-of-providers-accredited-to-deliver-itt-from-september-2024).

        If you have any questions, contact us at:
        [ittmentor.funding@education.gov.uk](mailto:ittmentor.funding@education.gov.uk)

        Kind regards,
        Claim funding for mentor training team
      EMAIL
    end
  end
end
