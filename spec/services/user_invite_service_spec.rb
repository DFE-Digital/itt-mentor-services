require "rails_helper"

RSpec.describe UserInviteService do
  subject { described_class.call(user, organisation) }

  describe "call" do
    context "when the user's service is Claims" do
      describe "when the organisation is a school" do
        let(:user) { create(:claims_user) }
        let(:organisation) { create(:school, :claims) }

        it "calls mailer with correct prams" do
          notify_mailer = double(:notify_mailer)
          expect(NotifyMailer).to receive(:send_organisation_invite_email).with(user, organisation, "http://claims.localhost/sign-in") { notify_mailer }
          expect(notify_mailer).to receive(:deliver_later)
          subject
        end
      end
    end

    context "when the user's service is Placements" do
      describe "when the organisation is a school" do
        let(:user) { create(:placements_user) }
        let(:organisation) { create(:school, :placements) }

        it "calls mailer with correct prams" do
          notify_mailer = double(:notify_mailer)
          expect(NotifyMailer).to receive(:send_organisation_invite_email).with(user, organisation, "http://placements.localhost/sign-in") { notify_mailer }
          expect(notify_mailer).to receive(:deliver_later)
          subject
        end
      end

      describe "when the organisation is a provider" do
        let(:user) { create(:placements_user) }
        let(:organisation) { create(:placements_provider) }

        it "calls mailer with correct prams" do
          notify_mailer = double(:notify_mailer)
          expect(NotifyMailer).to receive(:send_organisation_invite_email).with(user, organisation, "http://placements.localhost/sign-in") { notify_mailer }
          expect(notify_mailer).to receive(:deliver_later)
          subject
        end
      end
    end
  end
end
