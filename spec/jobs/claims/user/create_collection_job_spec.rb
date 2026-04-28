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

      it "rate limits Claims::User::CreateAndDeliverJob scheduling" do
        stub_const("Claims::User::CreateCollectionJob::MAX_CREATE_AND_DELIVER_PER_MINUTE", 1)
        allow(Claims::User::CreateAndDeliverJob).to receive(:set).and_call_original

        described_class.perform_now(user_details:)

        expect(Claims::User::CreateAndDeliverJob).to have_received(:set).with(wait: 0.minutes)
        expect(Claims::User::CreateAndDeliverJob).to have_received(:set).with(wait: 1.minute)
      end

      context "when a user already exists" do
        before do
          create(:claims_user, schools: [school], email: "joe_bloggs@example.com")
        end

        it "does not enqueue a Claims::User::CreateAndDeliverJob" do
          expect {
            described_class.perform_now(user_details:)
          }.to have_enqueued_job(Claims::User::CreateAndDeliverJob).once
        end
      end
    end
  end
end
