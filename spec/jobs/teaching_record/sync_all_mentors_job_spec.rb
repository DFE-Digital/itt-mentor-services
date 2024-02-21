require "rails_helper"

RSpec.describe TeachingRecord::SyncAllMentorsJob, type: :job do
  let(:mentor_1) { create(:mentor, first_name: "Joe", last_name: "Bloggs") }
  let(:mentor_2) { create(:mentor, first_name: "Agatha", last_name: "Christie") }

  before do
    mentor_1
    mentor_2
  end

  describe "#perform" do
    it "enqueues a TRSUpdateMentorDetailsJob per Mentor in our database" do
      expect { described_class.perform_now }.to have_enqueued_job(
        TeachingRecord::SyncMentorJob,
      ).exactly(:twice)
    end
  end
end
