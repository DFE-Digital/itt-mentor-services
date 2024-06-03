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

          [http://claims.localhost/sign-in](http://claims.localhost/sign-in)

          If you need to create a DfE Sign-in account, you can do this after clicking "Sign in using DfE Sign-in"

          After creating a DfE Sign-in account, you will need to return to this email and [sign in to access the service](http://claims.localhost/sign-in).

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

    context "when user's service is Placements" do
      context "when organisation is school" do
        let(:user) { create(:placements_user) }
        let(:organisation) { create(:placements_school) }

        it "sends invitation email" do
          expect(invite_email.to).to contain_exactly(user.email)
          expect(invite_email.subject).to eq("Invitation to join Manage school placements")
          expect(invite_email.body).to have_content <<~EMAIL
            Dear #{user.first_name},

            You have been invited to join the Manage school placements service for #{organisation.name}.

            # Sign in to view placements

            If you have a DfE Sign-in account, you can use it to sign in:

            [http://placements.localhost/sign-in](http://placements.localhost/sign-in)

            If you need to create a DfE Sign-in account, you can do this after clicking "Sign in using DfE Sign-in"

            After creating a DfE Sign-in account, you will need to return to this email and [sign in to access the service](http://placements.localhost/sign-in).

            # Give feedback or report a problem

            If you have any questions or feedback, please contact the team at [Manage.SchoolPlacements@education.gov.uk](mailto:Manage.SchoolPlacements@education.gov.uk).

            Regards

            Manage school placements team
          EMAIL
        end

        context "when HostingEnvironment.env is 'production'" do
          before do
            allow(HostingEnvironment).to receive(:env).and_return("production")
          end

          it "does not prepend the hosting environment to the subject" do
            expect(invite_email.subject).to eq("Invitation to join Manage school placements")
          end
        end

        context "when HostingEnvironment.env is 'staging'" do
          before do
            allow(HostingEnvironment).to receive(:env).and_return("staging")
          end

          it "prepends the hosting environment to the subject" do
            expect(invite_email.subject).to eq("[STAGING] Invitation to join Manage school placements")
          end
        end
      end

      context "when organisation is provider" do
        let(:user) { create(:placements_user) }
        let(:organisation) { create(:placements_provider) }

        it "sends invitation email" do
          expect(invite_email.to).to contain_exactly(user.email)
          expect(invite_email.subject).to eq("Invitation to join Manage school placements")
          expect(invite_email.body).to have_content <<~EMAIL
            Dear #{user.first_name},

            You have been invited to join the Manage school placements service for #{organisation.name}.

            # Sign in to view placements

            If you have a DfE Sign-in account, you can use it to sign in:

            [http://placements.localhost/sign-in](http://placements.localhost/sign-in)

            If you need to create a DfE Sign-in account, you can do this after clicking "Sign in using DfE Sign-in"

            After creating a DfE Sign-in account, you will need to return to this email and [sign in to access the service](http://placements.localhost/sign-in).

            # Give feedback or report a problem

            If you have any questions or feedback, please contact the team at [Manage.SchoolPlacements@education.gov.uk](mailto:Manage.SchoolPlacements@education.gov.uk).

            Regards

            Manage school placements team
          EMAIL
        end

        context "when HostingEnvironment.env is 'production'" do
          before do
            allow(HostingEnvironment).to receive(:env).and_return("production")
          end

          it "does not prepend the hosting environment to the subject" do
            expect(invite_email.subject).to eq("Invitation to join Manage school placements")
          end
        end

        context "when HostingEnvironment.env is 'staging'" do
          before do
            allow(HostingEnvironment).to receive(:env).and_return("staging")
          end

          it "prepends the hosting environment to the subject" do
            expect(invite_email.subject).to eq("[STAGING] Invitation to join Manage school placements")
          end
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

    context "when user's service is Placements" do
      context "when organisation is a school" do
        let(:user) { create(:placements_user) }
        let(:organisation) { create(:placements_school) }

        it "sends expected message to user" do
          expect(removal_email.to).to contain_exactly user.email
          expect(removal_email.subject).to eq "You have been removed from Manage school placements"
          expect(removal_email.body).to have_content <<~EMAIL
            Dear #{user.first_name},

            You have been removed from the Manage school placements service for #{organisation.name}.

            # Give feedback or report a problem

            If you have any questions or feedback, please contact the team at [Manage.SchoolPlacements@education.gov.uk](mailto:Manage.SchoolPlacements@education.gov.uk).

            Regards

            Manage school placements team
          EMAIL
        end

        context "when HostingEnvironment.env is 'production'" do
          before do
            allow(HostingEnvironment).to receive(:env).and_return("production")
          end

          it "does not prepend the hosting environment to the subject" do
            expect(removal_email.subject).to eq("You have been removed from Manage school placements")
          end
        end

        context "when HostingEnvironment.env is 'staging'" do
          before do
            allow(HostingEnvironment).to receive(:env).and_return("staging")
          end

          it "prepends the hosting environment to the subject" do
            expect(removal_email.subject).to eq("[STAGING] You have been removed from Manage school placements")
          end
        end
      end

      context "when organisation is a provider" do
        let(:user) { create(:placements_user) }
        let(:organisation) { create(:placements_provider) }

        it "sends expected message to user" do
          expect(removal_email.to).to contain_exactly user.email
          expect(removal_email.subject).to eq "You have been removed from Manage school placements"
          expect(removal_email.body).to have_content <<~EMAIL
            Dear #{user.first_name},

            You have been removed from the Manage school placements service for #{organisation.name}.

            # Give feedback or report a problem

            If you have any questions or feedback, please contact the team at [Manage.SchoolPlacements@education.gov.uk](mailto:Manage.SchoolPlacements@education.gov.uk).

            Regards

            Manage school placements team
          EMAIL
        end

        context "when HostingEnvironment.env is 'production'" do
          before do
            allow(HostingEnvironment).to receive(:env).and_return("production")
          end

          it "does not prepend the hosting environment to the subject" do
            expect(removal_email.subject).to eq("You have been removed from Manage school placements")
          end
        end

        context "when HostingEnvironment.env is 'staging'" do
          before do
            allow(HostingEnvironment).to receive(:env).and_return("staging")
          end

          it "prepends the hosting environment to the subject" do
            expect(removal_email.subject).to eq("[STAGING] You have been removed from Manage school placements")
          end
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

          http://claims.localhost/schools/#{school.id}/claims/#{claim.id}

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
          expect(claim_confirmation_email.subject).to eq("Thank you for submitting your claim for mentor training")
        end
      end

      context "when HostingEnvironment.env is 'staging'" do
        before do
          allow(HostingEnvironment).to receive(:env).and_return("staging")
        end

        it "prepends the hosting environment to the subject" do
          expect(claim_confirmation_email.subject).to eq("[STAGING] Thank you for submitting your claim for mentor training")
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

          We have added a draft claim for mentor training for #{claim.school.name}.
            Your claim reference is #{claim.reference}.

          You can view the claim, edit and submit it on Claim funding for mentor training:

          http://claims.localhost/schools/#{school.id}/claims/#{claim.id}

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

  describe "#partnership_created_notification" do
    subject(:partnership_created_notification_email) do
      described_class.with(service: :placements)
        .partnership_created_notification(user, source_organisation, partner_organisation)
    end

    context "when partner organisation is a provider" do
      let(:source_organisation) { create(:placements_school, name: "School 1") }
      let(:partner_organisation) { create(:placements_provider, name: "Provider 1") }
      let(:user) { create(:placements_user, providers: [partner_organisation]) }

      it "sends a notification email to the user of the provider" do
        expect(partnership_created_notification_email.to).to contain_exactly(user.email)
        expect(partnership_created_notification_email.subject).to eq(
          "A school has added your organisation to its list of partner providers",
        )

        expect(partnership_created_notification_email.body).to have_content <<~EMAIL
          Dear #{user.full_name},

          You are receiving this notification because #{source_organisation.name} has added #{partner_organisation.name} to its list of partner providers.

          View or manage your list of partner schools http://placements.localhost/providers/#{partner_organisation.id}/partner_schools
        EMAIL
      end
    end

    context "when partner organisation is a school" do
      let(:source_organisation) { create(:placements_provider, name: "Provider 1") }
      let(:partner_organisation) { create(:placements_school, name: "School 1") }

      let(:user) { create(:placements_user, schools: [partner_organisation]) }

      it "sends a notification email to the user of the school" do
        expect(partnership_created_notification_email.to).to contain_exactly(user.email)
        expect(partnership_created_notification_email.subject).to eq(
          "An ITT provider has added your organisation to its list of partner schools",
        )
        expect(partnership_created_notification_email.body).to have_content <<~EMAIL
          Dear #{user.full_name},

          You are receiving this notification because #{source_organisation.name} has added #{partner_organisation.name} to its list of partner schools.

          View or manage your list of partner providers http://placements.localhost/schools/#{partner_organisation.id}/partner_providers
        EMAIL
      end
    end

    context "when partner organisation is not a school or provider" do
      let(:source_organisation) { create(:placements_provider, name: "Provider 1") }
      let(:partner_organisation) { nil }
      let(:user) { create(:placements_user) }

      it "raises an error" do
        expect { partnership_created_notification_email.to }.to raise_error(
          InvalidOrganisationError, "#partner_organisation must be either a Provider or School"
        )
      end
    end
  end

  describe "#partnership_destroyed_notification" do
    subject(:partnership_destroyed_notification_email) do
      described_class.with(service: :placements)
        .partnership_destroyed_notification(user, source_organisation, partner_organisation)
    end

    context "when partner organisation is a provider" do
      let(:source_organisation) { create(:placements_school, name: "School 1") }
      let(:partner_organisation) { create(:placements_provider, name: "Provider 1") }
      let(:user) { create(:placements_user, providers: [partner_organisation]) }

      it "sends a notification email to the user of the provider" do
        expect(partnership_destroyed_notification_email.to).to contain_exactly(user.email)
        expect(partnership_destroyed_notification_email.subject).to eq(
          "A school has removed your organisation from its list of partner providers",
        )
        expect(partnership_destroyed_notification_email.body).to have_content <<~EMAIL
          Dear #{user.full_name},

          You are receiving this notification because #{source_organisation.name} has removed #{partner_organisation.name} from its list of partner providers.

          View or manage your list of partner schools http://placements.localhost/providers/#{partner_organisation.id}/partner_schools
        EMAIL
      end
    end

    context "when partner organisation is a school" do
      let(:source_organisation) { create(:placements_provider, name: "Provider 1") }
      let(:partner_organisation) { create(:placements_school, name: "School 1") }

      let(:user) { create(:placements_user, schools: [partner_organisation]) }

      it "sends a notification email to the user of the school" do
        expect(partnership_destroyed_notification_email.to).to contain_exactly(user.email)
        expect(partnership_destroyed_notification_email.subject).to eq(
          "An ITT provider has removed your organisation from its list of partner schools",
        )
        expect(partnership_destroyed_notification_email.body).to have_content <<~EMAIL
          Dear #{user.full_name},

          You are receiving this notification because #{source_organisation.name} has removed #{partner_organisation.name} from its list of partner schools.

          View or manage your list of partner providers http://placements.localhost/schools/#{partner_organisation.id}/partner_providers
        EMAIL
      end
    end

    context "when partner organisation is not a school or provider" do
      let(:source_organisation) { create(:placements_provider, name: "Provider 1") }
      let(:partner_organisation) { nil }
      let(:user) { create(:placements_user) }

      it "raises an error" do
        expect { partnership_destroyed_notification_email.to }.to raise_error(
          InvalidOrganisationError, "#partner_organisation must be either a Provider or School"
        )
      end
    end
  end
end
