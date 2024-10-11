require "rails_helper"

RSpec.describe SupportUser::Invite do
  include ActiveJob::TestHelper

  it_behaves_like "a service object" do
    let(:params) { { support_user: build(:claims_support_user) } }
  end

  describe ".call" do
    subject(:invite_support_user) { described_class.call(support_user:) }

    context "when given a valid Claims Support User" do
      let(:support_user) { create(:claims_support_user) }

      it "enqueues an invitation email" do
        expect { invite_support_user }.to have_enqueued_mail(Claims::SupportUserMailer, :support_user_invitation)
          .with(support_user)
      end
    end

    context "when given a valid Placements Support User" do
      let(:support_user) { create(:placements_support_user) }

      it "enqueues an invitation email" do
        expect { invite_support_user }.to have_enqueued_mail(Placements::SupportUserMailer, :support_user_invitation)
          .with(support_user)
      end
    end
  end
end
