require "rails_helper"

RSpec.describe UserMailer, type: :mailer do
  describe "#user_membership_created_notification" do
    subject(:invite_email) { described_class.with(service: user.service).user_membership_created_notification(user, organisation) }

    context "when user's service is Claims" do
      let(:user) { create(:claims_user) }
      let(:organisation) { create(:claims_school) }

      it "sends the invitation" do
        expect(invite_email.to).to contain_exactly(user.email)
        expect(invite_email.subject).to eq("You have been invited to #{organisation.name}")
        expect(invite_email.body).to have_content <<~EMAIL
          Dear #{user.full_name},

          You have been invited to join the Claim funding for mentor training service for #{organisation.name}.

          Sign in here http://claims.localhost:3000/sign-in
        EMAIL
      end
    end

    context "when user's service is Placements" do
      context "when organisation is school" do
        let(:user) { create(:placements_user) }
        let(:organisation) { create(:placements_school) }

        it "sends invitation email" do
          expect(invite_email.to).to contain_exactly(user.email)
          expect(invite_email.subject).to eq("You have been invited to #{organisation.name}")
          expect(invite_email.body).to have_content <<~EMAIL
            Dear #{user.full_name},

            You have been invited to join the Manage school placements service for #{organisation.name}.

            Sign in here http://placements.localhost:3000/sign-in
          EMAIL
        end
      end

      context "when organisation is provider" do
        let(:user) { create(:placements_user) }
        let(:organisation) { create(:placements_provider) }

        it "sends invitation email" do
          expect(invite_email.to).to contain_exactly(user.email)
          expect(invite_email.subject).to eq("You have been invited to #{organisation.name}")
          expect(invite_email.body).to have_content <<~EMAIL
            Dear #{user.full_name},

            You have been invited to join the Manage school placements service for #{organisation.name}.

            Sign in here http://placements.localhost:3000/sign-in
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
        expect(removal_email.subject).to eq "You have been removed from #{organisation.name}"
        expect(removal_email.body).to have_content <<~EMAIL
          Dear #{user.full_name},

          You have been removed from the Claim funding for mentor training service for #{organisation.name}.
        EMAIL
      end
    end

    context "when user's service is Placements" do
      context "when organisation is a school" do
        let(:user) { create(:placements_user) }
        let(:organisation) { create(:placements_school) }

        it "sends expected message to user" do
          expect(removal_email.to).to contain_exactly user.email
          expect(removal_email.subject).to eq "You have been removed from #{organisation.name}"
          expect(removal_email.body).to have_content <<~EMAIL
            Dear #{user.full_name},

            You have been removed from the Manage school placements service for #{organisation.name}.
          EMAIL
        end
      end

      context "when organisation is a provider" do
        let(:user) { create(:placements_user) }
        let(:organisation) { create(:placements_provider) }

        it "sends expected message to user" do
          expect(removal_email.to).to contain_exactly user.email
          expect(removal_email.subject).to eq "You have been removed from #{organisation.name}"
          expect(removal_email.body).to have_content <<~EMAIL
            Dear #{user.full_name},

            You have been removed from the Manage school placements service for #{organisation.name}.
          EMAIL
        end
      end
    end
  end

  describe "#claim_submitted_notification" do
    subject(:claim_confirmation_email) { described_class.with(service: user.service).claim_submitted_notification(user, claim) }

    context "when a claim has been submitted" do
      let(:region) { create(:region, name: "A region", claims_funding_available_per_hour: Money.from_amount(53.60, "GBP")) }
      let(:user) { create(:claims_user) }
      let(:school) { create(:claims_school, region:) }
      let(:claim) { create(:claim, reference: "123") }

      it "sends the confirmation email" do
        create(:mentor_training, claim:, hours_completed: 10)

        expect(claim_confirmation_email.to).to contain_exactly(user.email)
        expect(claim_confirmation_email.subject).to eq("Your ITT mentor training claim has been submitted")
        expect(claim_confirmation_email.body.to_s.strip).to eq(<<~EMAIL.strip)
          Reference: 123\r
          Amount: £536.00\r\n\r
          Link to claim: http://claims.localhost:3000/schools/#{claim.school.id}/claims/#{claim.id}
        EMAIL
      end
    end
  end
end
