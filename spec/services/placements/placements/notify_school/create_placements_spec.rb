require "rails_helper"

RSpec.describe Placements::Placements::NotifySchool::CreatePlacements do
  subject(:notify_school_service) { described_class.call(user:, school:, placements:) }

  it_behaves_like "a service object" do
    let(:params) { { user: create(:placements_user), school: create(:school), placements: [create(:placement)] } }
  end

  describe "#call" do
    let(:placements) { [create(:placement)] }
    let(:school) { create(:placements_school) }
    let!(:user) { create(:placements_user, schools: [school]) }

    it "sends a notification email to the user" do
      expect { notify_school_service }.to have_enqueued_mail(
        Placements::SchoolUserMailer,
        :placement_information_added_notification,
      ).with(
        user, school, placements
      )
    end
  end
end
