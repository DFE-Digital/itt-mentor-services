require "rails_helper"

RSpec.describe UserMailer, type: :mailer do
  describe "#user_membership_created_notification" do
    subject(:invite_email) { described_class.with(service: user.service).user_membership_created_notification(user, organisation) }

    context "when user's service is Claims" do
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

          http://claims.localhost:3000/sign-in

          If you need to create a DfE Sign-in account, you can do this after clicking "Sign in using DfE Sign-in"

          After creating a DfE Sign-in account, you will need to return to this email and [sign in to access the service](http://claims.localhost:3000/sign-in).

          # Give feedback or report a problem

          If you have any questions or feedback, please contact the team at ittmentor.funding@digital.education.gov.uk.

          Regards

          Claim funding for mentor training team
        EMAIL
      end
    end

    context "when user's service is Placements" do
      context "when organisation is school" do
        let(:user) { create(:placements_user) }
        let(:organisation) { create(:placements_school) }

        it "sends invitation email" do
          expect(invite_email.to).to contain_exactly(user.email)
          expect(invite_email.subject).to eq("Invitation to join Claim funding for mentor training")
          expect(invite_email.body).to have_content <<~EMAIL
            Dear #{user.first_name},

            You have been invited to join the Manage school placements service for #{organisation.name}.

            # Sign in to submit claims

            If you have a DfE Sign-in account, you can use it to sign in:

            http://placements.localhost:3000/sign-in

            If you need to create a DfE Sign-in account, you can do this after clicking "Sign in using DfE Sign-in"

            After creating a DfE Sign-in account, you will need to return to this email and [sign in to access the service](http://placements.localhost:3000/sign-in).

            # Give feedback or report a problem

            If you have any questions or feedback, please contact the team at ittmentor.funding@digital.education.gov.uk.

            Regards

            Claim funding for mentor training team
          EMAIL
        end
      end

      context "when organisation is provider" do
        let(:user) { create(:placements_user) }
        let(:organisation) { create(:placements_provider) }

        it "sends invitation email" do
          expect(invite_email.to).to contain_exactly(user.email)
          expect(invite_email.subject).to eq("Invitation to join Claim funding for mentor training")
          expect(invite_email.body).to have_content <<~EMAIL
            Dear #{user.first_name},

            You have been invited to join the Manage school placements service for #{organisation.name}.

            # Sign in to submit claims

            If you have a DfE Sign-in account, you can use it to sign in:

            http://placements.localhost:3000/sign-in

            If you need to create a DfE Sign-in account, you can do this after clicking "Sign in using DfE Sign-in"

            After creating a DfE Sign-in account, you will need to return to this email and [sign in to access the service](http://placements.localhost:3000/sign-in).

            # Give feedback or report a problem

            If you have any questions or feedback, please contact the team at ittmentor.funding@digital.education.gov.uk.

            Regards

            Claim funding for mentor training team
          EMAIL
        end
      end
    end
  end

  describe "#user_membership_destroyed_notification" do
    subject(:removal_email) { described_class.with(service: user.service).user_membership_destroyed_notification(user, organisation) }

    context "when user's service is Claims" do
      let(:user) { create(:claims_user) }
      let(:organisation) { create(:claims_school) }

      it "sends expected message to user" do
        expect(removal_email.to).to contain_exactly user.email
        expect(removal_email.subject).to eq "You have been removed from Claim funding for mentor training"
        expect(removal_email.body).to have_content <<~EMAIL
          Dear #{user.first_name},

          You have been removed from the Claim funding for mentor training service for #{organisation.name}.

          # Give feedback or report a problem

          If you have any questions or feedback, please contact the team at ittmentor.funding@digital.education.gov.uk.

          Regards

          Claim funding for mentor training team
        EMAIL
      end
    end

    context "when user's service is Placements" do
      context "when organisation is a school" do
        let(:user) { create(:placements_user) }
        let(:organisation) { create(:placements_school) }

        it "sends expected message to user" do
          expect(removal_email.to).to contain_exactly user.email
          expect(removal_email.subject).to eq "You have been removed from Claim funding for mentor training"
          expect(removal_email.body).to have_content <<~EMAIL
            Dear #{user.first_name},

            You have been removed from the Claim funding for mentor training service for #{organisation.name}.

            # Give feedback or report a problem

            If you have any questions or feedback, please contact the team at ittmentor.funding@digital.education.gov.uk.

            Regards

            Claim funding for mentor training team
          EMAIL
        end
      end

      context "when organisation is a provider" do
        let(:user) { create(:placements_user) }
        let(:organisation) { create(:placements_provider) }

        it "sends expected message to user" do
          expect(removal_email.to).to contain_exactly user.email
          expect(removal_email.subject).to eq "You have been removed from Claim funding for mentor training"
          expect(removal_email.body).to have_content <<~EMAIL
            Dear #{user.first_name},

            You have been removed from the Claim funding for mentor training service for #{organisation.name}.

            # Give feedback or report a problem

            If you have any questions or feedback, please contact the team at ittmentor.funding@digital.education.gov.uk.

            Regards

            Claim funding for mentor training team
          EMAIL
        end
      end
    end
  end

  describe "#claim_submitted_notification" do
    subject(:claim_confirmation_email) { described_class.with(service: user.service).claim_submitted_notification(user, claim) }

    context "when a claim has been submitted" do
      let(:user) { create(:claims_user) }
      let(:school) { create(:claims_school, region: regions(:inner_london)) }
      let(:claim) { create(:claim, reference: "123", school:) }

      it "sends the confirmation email" do
        create(:mentor_training, claim:, hours_completed: 10)

        expect(claim_confirmation_email.to).to contain_exactly(user.email)
        expect(claim_confirmation_email.subject).to eq("Thank you for submitting your claim for mentor training")
        expect(claim_confirmation_email.body.to_s.strip).to eq(<<~EMAIL.strip)
          Dear #{user.first_name},

          You have successfully submitted a claim for mentor training for #{claim.school.name}.

          Your claim reference is #{claim.reference}.

          You can view your claim on Claim funding for mentor training:

          http://claims.localhost:3000/schools/#{school.id}/claims/#{claim.id}

          # Give feedback or report a problem

          If you have any questions or feedback, please contact the team at ittmentor.funding@digital.education.gov.uk.

          Regards

          Claim funding for mentor training team
        EMAIL
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

          We have added a draft claim for mentor training for #{claim.school.name}.
            Your claim reference is #{claim.reference}.

          You can view the claim, edit and submit it on Claim funding for mentor training:

          http://claims.localhost:3000/schools/#{school.id}/claims/#{claim.id}

          # Give feedback or report a problem

          If you have any questions or feedback, please contact the team at ittmentor.funding@digital.education.gov.uk.

          Regards

          Claim funding for mentor training team
        EMAIL
      end
    end
  end
end
