require "rails_helper"

RSpec.describe UserMailer, type: :mailer do
  describe "#invitation_email" do
    subject(:invite_email) { described_class.invitation_email(user, organisation, "sign_in_url") }

    context "when user's service is Claims" do
      let(:user) { create(:claims_user) }
      let(:organisation) { create(:claims_school) }

      it "sends the invitation" do
        expect(invite_email.to).to contain_exactly(user.email)
        expect(invite_email.subject).to eq("You have been invited to #{organisation.name}")

        expect(invite_email.body.encoded).to eq(
          "Dear #{user.full_name} \r\n\r\n You have been invited to join the claims" \
            " service for #{organisation.name}.\r\n\r\n Sign in here sign_in_url",
        )
      end
    end

    context "when user's service is Placements" do
      context "when organisation is school" do
        let(:user) { create(:placements_user) }
        let(:organisation) { create(:placements_school) }

        it "sends invitation email" do
          expect(invite_email.to).to contain_exactly(user.email)
          expect(invite_email.subject).to eq("You have been invited to #{organisation.name}")
          expect(invite_email.body.encoded).to eq(
            "Dear #{user.full_name} \r\n\r\n You have been invited to join the school placements" \
            " service for #{organisation.name}.\r\n\r\n Sign in here sign_in_url",
          )
        end
      end

      context "when organisation is provider" do
        let(:user) { create(:placements_user) }
        let(:organisation) { create(:placements_provider) }

        it "sends invitation email" do
          expect(invite_email.to).to contain_exactly(user.email)
          expect(invite_email.subject).to eq("You have been invited to #{organisation.name}")
          expect(invite_email.body.encoded).to eq(
            "Dear #{user.full_name} \r\n\r\n You have been invited to join the school placements" \
              " service for #{organisation.name}.\r\n\r\n Sign in here sign_in_url",
          )
        end
      end
    end
  end

  describe "#removal_email" do
    subject(:removal_email) { described_class.removal_email(user, organisation) }

    context "when user's service is Placements" do
      context "when organisation is a school" do
        let(:user) { create(:placements_user) }
        let(:organisation) { create(:placements_school) }

        it "sends expected message to user" do
          expect(removal_email.to).to contain_exactly user.email
          expect(removal_email.subject).to eq "You have been removed from #{organisation.name}"
          expect(removal_email.body.encoded).to eq("Dear #{user.full_name} \r\n\r\n You have been removed from the " \
                                         "school placements service for #{organisation.name}.")
        end
      end

      context "when organisation is a provider" do
        let(:user) { create(:placements_user) }
        let(:organisation) { create(:placements_provider) }

        it "sends expected message to user" do
          expect(removal_email.to).to contain_exactly user.email
          expect(removal_email.subject).to eq "You have been removed from #{organisation.name}"
          expect(removal_email.body.encoded).to eq("Dear #{user.full_name} \r\n\r\n You have been removed from the " \
            "school placements service for #{organisation.name}.")
        end
      end
    end

    context "when user's service is Claims" do
      let(:user) { create(:claims_user) }
      let(:organisation) { create(:claims_school) }

      it "sends expected message to user" do
        expect(removal_email.to).to contain_exactly user.email
        expect(removal_email.subject).to eq "You have been removed from #{organisation.name}"
        expect(removal_email.body.encoded).to eq("Dear #{user.full_name} \r\n\r\n You have been removed from the claims" \
          " service for #{organisation.name}.")
      end
    end
  end
end
