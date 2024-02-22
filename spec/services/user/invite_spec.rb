require "rails_helper"

RSpec.describe User::Invite do
  subject(:user_invite_service) { described_class.call(user:, organisation:) }

  describe "call" do
    context "when the user's service is Claims" do
      describe "when the organisation is a school" do
        let(:user) { create(:claims_user) }
        let(:organisation) { create(:claims_school) }

        it "calls mailer with correct prams" do
          expect { user_invite_service }.to have_enqueued_mail(UserMailer, :user_membership_created_notification).with(params: { service: :claims }, args: [user, organisation])
        end
      end
    end

    context "when the user's service is Placements" do
      describe "when the organisation is a school" do
        let(:user) { create(:placements_user) }
        let(:organisation) { create(:placements_school) }

        it "calls mailer with correct prams" do
          expect { user_invite_service }.to have_enqueued_mail(UserMailer, :user_membership_created_notification).with(params: { service: :placements }, args: [user, organisation])
        end
      end

      describe "when the organisation is a provider" do
        let(:user) { create(:placements_user) }
        let(:organisation) { create(:placements_provider) }

        it "calls mailer with correct prams" do
          expect { user_invite_service }.to have_enqueued_mail(UserMailer, :user_membership_created_notification).with(params: { service: :placements }, args: [user, organisation])
        end
      end
    end
  end
end
