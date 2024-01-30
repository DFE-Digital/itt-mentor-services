require "rails_helper"

RSpec.describe RemoveUserService do
  subject { described_class.call(user, organisation) }

  describe "#call" do
    context "the user is a placements user" do
      let(:user) { create(:placements_user) }
      let(:organisation) { create(:placements_school) }
      let!(:membership) { create(:membership, user:, organisation:) }

      it "calls mailer with correct params" do
        user_mailer = double(:user_mailer)
        expect(UserMailer).to receive(:removal_email).with(user, organisation) { user_mailer }
        expect(user_mailer).to receive(:deliver_later)

        subject
        expect { membership.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "the user is a claims user" do
      let(:user) { create(:claims_user) }
      let(:organisation) { create(:claims_school) }
      let!(:membership) { create(:membership, user:, organisation:) }

      it "calls mailer with correct params" do
        user_mailer = double(:user_mailer)
        expect(UserMailer).to receive(:removal_email).with(user, organisation) { user_mailer }
        expect(user_mailer).to receive(:deliver_later)

        subject

        expect { membership.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
