require "rails_helper"

RSpec.describe UserInviteService do
  include ActiveJob::TestHelper

  subject { described_class.call(user, organisation, "") }

  describe "invite" do
    context "when the user's service is Claims" do
      context "when the organisation is a school" do
        let(:user) { create(:claims_user) }
        let(:organisation) { create(:school, :claims) }

        it "assigns the user to the organisation" do
          expect { subject }.to change(Membership, :count).by(1).and change(enqueued_jobs, :size).by(1)
          expect(user.schools).to contain_exactly(organisation)
        end
      end
    end

    context "when the user's service is Placements" do
      context "when the organisation is a school" do
        let(:user) { create(:placements_user) }
        let(:organisation) { create(:school, :placements) }

        it "assigns the user to the organisation" do
          expect { subject }.to change(
            Membership, :count
          ).by(1).and change(enqueued_jobs, :size).by(1)
          expect(user.schools).to contain_exactly(organisation)
        end
      end

      context "when the organisation is a provider" do
        let(:user) { create(:placements_user) }
        let(:organisation) { create(:provider, placements: true) }

        it "assigns the user to the organisation" do
          expect { subject }.to change(
            Membership, :count
          ).by(1).and change(enqueued_jobs, :size).by(1)
          expect(user.providers).to contain_exactly(organisation)
        end
      end
    end
  end
end
