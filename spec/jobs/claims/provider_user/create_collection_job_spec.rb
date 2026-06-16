require "rails_helper"

RSpec.describe Claims::ProviderUser::CreateCollectionJob, type: :job do
  describe "#perform" do
    let(:provider) { create(:claims_provider) }
    let(:provider_user_details) do
      [
        {
          provider_id: provider.id,
          first_name: "Joe",
          last_name: "Bloggs",
          email: "joe_bloggs@example.com",
        },
        {
          provider_id: provider.id,
          first_name: "Sue",
          last_name: "Doe",
          email: "sue_doe@example.com",
        },
      ]
    end

    it "enqueues the job in the default queue" do
      expect {
        described_class.perform_later(provider_user_details:)
      }.to have_enqueued_job(described_class).on_queue("default")
    end

    context "when the array of user details is over 500 elements" do
      let(:provider_user_details) { 600.times.map { |_i| {} } }

      it "breaks the job into smaller jobs" do
        expect {
          described_class.perform_now(provider_user_details:)
        }.to have_enqueued_job(described_class).twice
      end
    end

    context "when the array of user details is less than 500 elements" do
      it "enqueues a Claims::ProviderUser::CreateAndDeliverJob per user details" do
        expect {
          described_class.perform_now(provider_user_details:)
        }.to have_enqueued_job(Claims::ProviderUser::CreateAndDeliverJob).twice
      end

      it "rate limits Claims::ProviderUser::CreateAndDeliverJob scheduling" do
        stub_const("Claims::ProviderUser::CreateCollectionJob::MAX_CREATE_AND_DELIVER_PER_MINUTE", 1)
        allow(Claims::ProviderUser::CreateAndDeliverJob).to receive(:set).and_call_original

        described_class.perform_now(provider_user_details:)

        expect(Claims::ProviderUser::CreateAndDeliverJob).to have_received(:set).with(wait: 0.minutes)
        expect(Claims::ProviderUser::CreateAndDeliverJob).to have_received(:set).with(wait: 1.minute)
      end

      context "when a user already exists" do
        before do
          create(:claims_provider_user, providers: [provider], email: "joe_bloggs@example.com")
        end

        it "does not enqueue a Claims::ProviderUser::CreateAndDeliverJob" do
          expect {
            described_class.perform_now(provider_user_details:)
          }.to have_enqueued_job(Claims::ProviderUser::CreateAndDeliverJob).once
        end
      end
    end
  end
end
