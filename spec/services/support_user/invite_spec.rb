require "rails_helper"

RSpec.describe SupportUser::Invite do
  include ActiveJob::TestHelper

  describe ".call" do
    subject(:invite_support_user) { described_class.call(support_user:) }

    context "when given a valid Claims Support User" do
      let(:support_user) { create(:claims_support_user) }

      it "enqueues an invitation email" do
        expect { invite_support_user }.to have_enqueued_mail(SupportUserMailer, :support_user_invitation)
          .with(params: { service: :claims }, args: [support_user])
      end
    end

    context "when given a valid Placements Support User" do
      let(:support_user) { create(:placements_support_user) }

      it "enqueues an invitation email" do
        expect { invite_support_user }.to have_enqueued_mail(SupportUserMailer, :support_user_invitation)
          .with(params: { service: :placements }, args: [support_user])
      end
    end
  end
end
