require "rails_helper"

RSpec.describe SupportUser::Invite do
  include ActiveJob::TestHelper

  describe ".call" do
    subject { described_class.call(support_user:) }

    context "when given a valid Support User" do
      let(:support_user) { build(:claims_support_user) }

      it "returns true" do
        expect(subject).to be(true)
      end

      it "creates a user" do
        expect { subject }.to change { User.count }.by(1)
      end

      it "enqueues an invitation email" do
        expect { subject }.to change { enqueued_jobs.size }.by(1)
      end
    end

    context "when given an invalid Support User" do
      let(:support_user) { build(:claims_support_user, first_name: nil) }

      it "returns false" do
        expect(subject).to be(false)
      end

      it "does not create a user" do
        expect { subject }.to_not(change { User.count })
      end

      it "does not send an email" do
        expect { subject }.to_not(change { enqueued_jobs.size })
      end
    end
  end
end
