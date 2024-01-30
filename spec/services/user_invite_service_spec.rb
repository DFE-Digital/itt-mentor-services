require "rails_helper"

RSpec.describe UserInviteService do
  subject { described_class.call(user, organisation) }

  describe "call" do
    context "when the user's service is Claims" do
      describe "when the organisation is a school" do
        let(:user) { create(:claims_user) }
        let(:organisation) { create(:school, :claims) }
        let(:service) { "claims" }

        it "calls mailer with correct prams" do
          user_mailer = double(:user_mailer)
          expect(UserMailer).to receive(:invitation_email).with(user, organisation, "http://claims.localhost/sign-in") { user_mailer }
          expect(user_mailer).to receive(:deliver_later)
          subject
        end
      end
    end

    context "when the user's service is Placements" do
      let(:service) { "placements" }

      describe "when the organisation is a school" do
        let(:user) { create(:placements_user) }
        let(:organisation) { create(:school, :placements) }

        it "calls mailer with correct prams" do
          user_mailer = double(:user_mailer)
          expect(UserMailer).to receive(:invitation_email).with(user, organisation, "http://placements.localhost/sign-in") { user_mailer }
          expect(user_mailer).to receive(:deliver_later)
          subject
        end
      end

      describe "when the organisation is a provider" do
        let(:user) { create(:placements_user) }
        let(:organisation) { create(:placements_provider) }

        it "calls mailer with correct prams" do
          user_mailer = double(:user_mailer)
          expect(UserMailer).to receive(:invitation_email).with(user, organisation, "http://placements.localhost/sign-in") { user_mailer }
          expect(user_mailer).to receive(:deliver_later)
          subject
        end
      end
    end
  end
end
