require "rails_helper"

RSpec.describe Placements::Partnerships::Notify::Removal do
  let(:provider) { create(:placements_provider) }
  let(:school) { create(:placements_school) }

  it_behaves_like "a service object" do
    let(:params) do
      {
        source_organisation: provider,
        partner_organisation: school,
      }
    end
  end

  describe "#call" do
    context "when the partner organisation is a provider" do
      subject(:partnership_notify_removal) do
        described_class.call(
          source_organisation: school,
          partner_organisation: provider,
        )
      end

      let!(:user_1) { create(:placements_user, providers: [provider]) }
      let!(:user_2) { create(:placements_user, providers: [provider]) }

      it "sends a notification email to every user for the school" do
        expect { partnership_notify_removal }.to have_enqueued_mail(
          UserMailer,
          :partnership_destroyed_notification,
        ).with(
          params: { service: :placements },
          args: [user_1, school, provider],
        ).and have_enqueued_mail(
          UserMailer,
          :partnership_destroyed_notification,
        ).with(
          params: { service: :placements },
          args: [user_2, school, provider],
        )
      end
    end

    context "when the partner organisation is a school" do
      subject(:partnership_notify_removal) do
        described_class.call(
          source_organisation: provider,
          partner_organisation: school,
        )
      end

      let!(:user_1) { create(:placements_user, schools: [school]) }
      let!(:user_2) { create(:placements_user, schools: [school]) }

      it "sends a notification email to every user for a provider" do
        expect { partnership_notify_removal }.to have_enqueued_mail(
          UserMailer,
          :partnership_destroyed_notification,
        ).with(
          params: { service: :placements },
          args: [user_1, provider, school],
        ).and have_enqueued_mail(
          UserMailer,
          :partnership_destroyed_notification,
        ).with(
          params: { service: :placements },
          args: [user_2, provider, school],
        )
      end
    end
  end
end
