require "rails_helper"

RSpec.describe UserMailer, type: :mailer do
  describe "#user_invitation_notification" do
    subject(:invite_email) { described_class.with(service: user.service).user_invitation_notification(user, organisation) }

    context "when user's service is Claims" do
      let(:user) { create(:claims_user) }
      let(:organisation) { create(:claims_school) }

      it "sends the invitation" do
        expect(invite_email.to).to contain_exactly(user.email)
        expect(invite_email.subject).to eq("You have been invited to #{organisation.name}")
        expect(invite_email.body).to have_content <<~EMAIL
          Dear #{user.full_name},

          You have been invited to join the Claim funding for mentors service for #{organisation.name}.

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

  describe "#user_removal_notification" do
    subject(:removal_email) { described_class.with(service: user.service).user_removal_notification(user, organisation) }

    context "when user's service is Claims" do
      let(:user) { create(:claims_user) }
      let(:organisation) { create(:claims_school) }

      it "sends expected message to user" do
        expect(removal_email.to).to contain_exactly user.email
        expect(removal_email.subject).to eq "You have been removed from #{organisation.name}"
        expect(removal_email.body).to have_content <<~EMAIL
          Dear #{user.full_name},

          You have been removed from the Claim funding for mentors service for #{organisation.name}.
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
end
