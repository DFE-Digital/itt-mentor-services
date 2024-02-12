require "rails_helper"

RSpec.describe SupportUser::Invite do
  include ActiveJob::TestHelper

  describe ".call" do
    subject(:invite_support_user) { described_class.call(support_user:) }

    context "when given a valid Support User" do
      let(:support_user) { build(:claims_support_user) }

      it "returns true" do
        expect(invite_support_user).to be(true)
      end

      it "creates a user" do
        expect { invite_support_user }.to change(User, :count).by(1)
      end

      it "enqueues an invitation email" do
        expect { invite_support_user }.to change(enqueued_jobs, :size).by(1)
      end
    end

    context "when given an invalid Support User" do
      let(:support_user) { build(:claims_support_user, first_name: nil) }

      it "raises error" do
        expect { invite_support_user }.to raise_error ActiveRecord::RecordInvalid
      end
    end
  end
end
