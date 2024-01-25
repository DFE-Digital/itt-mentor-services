require "rails_helper"

RSpec.describe UserInviteService do
  subject { described_class.call(user, organisation, service) }

  describe "call" do
    context "when the user's service is Claims" do
      describe "when the organisation is a school" do
        let(:user) { create(:claims_user) }
        let(:organisation) { create(:school, :claims) }
        let(:service) { "claims" }

        it "calls mailer with correct prams" do
          notify_mailer = double(:notify_mailer)
          expect(NotifyMailer).to receive(:send_organisation_invite_email).with(user, organisation, service, "http://claims.localhost/sign-in") { notify_mailer }
          expect(notify_mailer).to receive(:deliver_later)
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
          notify_mailer = double(:notify_mailer)
          expect(NotifyMailer).to receive(:send_organisation_invite_email).with(user, organisation, service, "http://placements.localhost/sign-in") { notify_mailer }
          expect(notify_mailer).to receive(:deliver_later)
          subject
        end
      end

      describe "when the organisation is a provider" do
        let(:user) { create(:placements_user) }
        let(:organisation) { create(:placements_provider) }

        it "calls mailer with correct prams" do
          notify_mailer = double(:notify_mailer)
          expect(NotifyMailer).to receive(:send_organisation_invite_email).with(user, organisation, service, "http://placements.localhost/sign-in") { notify_mailer }
          expect(notify_mailer).to receive(:deliver_later)
          subject
        end
      end
    end
  end
end
