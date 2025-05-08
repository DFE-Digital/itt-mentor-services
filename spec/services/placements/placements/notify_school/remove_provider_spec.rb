require "rails_helper"

RSpec.describe Placements::Placements::NotifySchool::RemoveProvider do
  subject(:notify_school_service) { described_class.call(school:, provider:, placement:) }

  it_behaves_like "a service object" do
    let(:params) { { school: create(:school), provider: create(:provider), placement: create(:placement) } }
  end

  describe "#call" do
    let!(:provider) { create(:placements_provider) }
    let(:placement) { create(:placement) }
    let(:school) { create(:placements_school) }
    let!(:user_1) { create(:placements_user, schools: [school]) }
    let!(:user_2) { create(:placements_user, schools: [school]) }

    it "sends a notification email to every user belonging to the provider" do
      expect { notify_school_service }.to have_enqueued_mail(
        Placements::SchoolUserMailer,
        :placement_provider_removed_notification,
      ).with(
        user_1, school, provider, placement
      ).and have_enqueued_mail(
        Placements::SchoolUserMailer,
        :placement_provider_removed_notification,
      ).with(
        user_2, school, provider, placement
      )
    end
  end
end
