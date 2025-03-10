require "rails_helper"

RSpec.describe Placements::Placements::NotifyProvider::Assign do
  subject(:notify_provider_service) { described_class.call(provider:, placement:) }

  it_behaves_like "a service object" do
    let(:params) { { provider: create(:provider), placement: create(:placement) } }
  end

  describe "#call" do
    let!(:provider) { create(:placements_provider) }
    let(:placement) { create(:placement) }
    let!(:user_1) { create(:placements_user, providers: [provider]) }
    let!(:user_2) { create(:placements_user, providers: [provider]) }

    it "sends a notification email to every user belonging to the provider" do
      expect { notify_provider_service }.to have_enqueued_mail(
        Placements::ProviderUserMailer,
        :placement_provider_assigned_notification,
      ).with(
        user_1, provider, placement
      ).and have_enqueued_mail(
        Placements::ProviderUserMailer,
        :placement_provider_assigned_notification,
      ).with(
        user_2, provider, placement
      )
    end
  end
end
