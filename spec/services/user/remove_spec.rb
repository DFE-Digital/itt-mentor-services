require "rails_helper"

RSpec.describe User::Remove do
  subject(:remove_user_service) { described_class.call(user:, organisation:) }

  it_behaves_like "a service object" do
    let(:params) { { user: create(:claims_user), organisation: create(:claims_school) } }
  end

  describe "#call" do
    context "when the user is a claims user" do
      let(:user) { create(:claims_user) }
      let(:organisation) { create(:claims_school) }
      let!(:membership) { create(:user_membership, user:, organisation:) }

      it "calls mailer with correct params" do
        expect { remove_user_service }.to have_enqueued_mail(Claims::UserMailer, :user_membership_destroyed_notification).with(user, organisation)

        expect { membership.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "when the user is a placements user" do
      let(:user) { create(:placements_user) }
      let(:organisation) { create(:placements_school) }
      let!(:membership) { create(:user_membership, user:, organisation:) }

      it "calls mailer with correct params" do
        expect { remove_user_service }.to have_enqueued_mail(Placements::UserMailer, :user_membership_destroyed_notification).with(user, organisation)

        expect { membership.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
