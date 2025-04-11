require "rails_helper"

RSpec.describe Claims::UserMailer, type: :mailer do
  describe "#user_membership_created_notification" do
    subject(:invite_email) { described_class.user_membership_created_notification(user, organisation) }

    let(:user) { create(:claims_user) }
    let(:organisation) { create(:claims_school) }

    it "sends the invitation" do
      expect(invite_email.to).to contain_exactly(user.email)
      expect(invite_email.subject).to eq("Invitation to join Claim funding for mentor training")
      expect(invite_email.body).to have_content <<~EMAIL
        Dear #{user.first_name},

        You have been invited to join the Claim funding for mentor training service for #{organisation.name}.

        # Sign in to submit claims

        If you have a DfE Sign-in account, you can use it to sign in:

        [http://claims.localhost/sign-in?utm_campaign=school&utm_medium=notification&utm_source=email](http://claims.localhost/sign-in?utm_campaign=school&utm_medium=notification&utm_source=email)

        If you need to create a DfE Sign-in account, you can do this after clicking "Sign in using DfE Sign-in"

        After creating a DfE Sign-in account, you will need to return to this email and [sign in to access the service](http://claims.localhost/sign-in?utm_campaign=school&utm_medium=notification&utm_source=email).

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
end
