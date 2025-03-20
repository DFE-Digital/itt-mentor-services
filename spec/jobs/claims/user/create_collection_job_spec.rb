require "rails_helper"

RSpec.describe Claims::User::CreateCollectionJob, type: :job do
  describe "#perform" do
    let(:school) { create(:claims_school) }
    let(:user_details) do
      [
        {
          school_id: school.id,
          first_name: "Joe",
          last_name: "Bloggs",
          email: "joe_bloggs@example.com",
        },
        {
          school_id: school.id,
          first_name: "Sue",
          last_name: "Doe",
          email: "sue_doe@example.com",
        },
      ]
    end

    it "enqueues the job in the default queue" do
      expect {
        described_class.perform_later(user_details:)
      }.to have_enqueued_job(described_class).on_queue("default")
    end

    context "when the array of user details is over 500 elements" do
      let(:user_details) { 600.times.map { |_i| {} } }

      it "breaks the job into smaller jobs" do
        expect {
          described_class.perform_now(user_details:)
        }.to have_enqueued_job(described_class).twice
      end
    end

    context "when the array of user details is less than 500 elements" do
      it "enqueues a Claims::User::CreateAndDeliverJob per user details" do
        expect {
          described_class.perform_now(user_details:)
        }.to have_enqueued_job(Claims::User::CreateAndDeliverJob).twice
      end
    end
  end
end
