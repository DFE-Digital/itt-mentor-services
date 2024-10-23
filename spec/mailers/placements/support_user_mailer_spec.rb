require "rails_helper"

RSpec.describe Placements::SupportUserMailer, type: :mailer do
  describe "#support_user_invitation" do
    subject(:invite_email) { described_class.support_user_invitation(user) }

    let(:user) { create(:placements_support_user, first_name: "John", last_name: "Doe") }

    it "is addressed to the user's email and contains a link to the placements sign in url" do
      expect(invite_email.to).to contain_exactly(user.email)
      expect(invite_email.subject).to eq("Your invite to the Manage school placements service")
      expect(invite_email.body).to have_content <<~EMAIL
        John,

        You have been invited to join the Manage school placements service as a support user.

        [Sign in to the support console for Manage school placements](http://placements.localhost/sign-in)

        If you need help [contact the service team on Slack](https://ukgovernmentdfe.slack.com/archives/C04MLBVP876).

        Manage school placements service
      EMAIL
    end

    context "when HostingEnvironment.env is 'production'" do
      before do
        allow(HostingEnvironment).to receive(:env).and_return("production")
      end

      it "does not prepend the hosting environment to the subject" do
        expect(invite_email.subject).to eq("Your invite to the Manage school placements service")
      end
    end

    context "when HostingEnvironment.env is 'staging'" do
      before do
        allow(HostingEnvironment).to receive(:env).and_return("staging")
      end

      it "prepends the hosting environment to the subject" do
        expect(invite_email.subject).to eq("[STAGING] Your invite to the Manage school placements service")
      end
    end
  end

  describe "#support_user_removal_notification" do
    subject(:removal_email) { described_class.with(service: "placements").support_user_removal_notification(user) }

    let(:user) { create(:placements_support_user, first_name: "John", last_name: "Doe") }

    it "is addressed to the user's email and contains a link to the placements sign in url" do
      expect(removal_email.to).to contain_exactly(user.email)
      expect(removal_email.subject).to eq("You have been removed from Manage school placements")
      expect(removal_email.body).to have_content <<~EMAIL
        Dear John,

        You have been removed from the Manage school placements service.

        If you think this was a mistake, [contact the service team on Slack](https://ukgovernmentdfe.slack.com/archives/C04MLBVP876).

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
