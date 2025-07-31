require "rails_helper"

describe NotifyRateLimiter do
  let(:collection) { Claims::User.all }
  let(:mailer) { "Claims::UserMailer" }
  let(:mailer_method) { :claims_have_not_been_submitted }
  let(:mailer_args) { [] }
  let(:mailer_kwargs) { {} }

  before do
    create_list(:claims_user, 150)

    allow(NotifyRateLimiterJob).to receive(:perform_later).with(0.minutes, anything, mailer, mailer_method, mailer_args, mailer_kwargs)
    allow(NotifyRateLimiterJob).to receive(:perform_later).with(1.minute, anything, mailer, mailer_method, mailer_args, mailer_kwargs)
  end

  it_behaves_like "a service object" do
    let(:params) { { collection:, mailer:, mailer_method: } }
  end

  describe "#call" do
    it "calls NotifyRateLimiterJob for each batch of users" do
      described_class.call(collection:, mailer:, mailer_method:)

      expect(NotifyRateLimiterJob).to have_received(:perform_later).with(0.minutes, anything, mailer, mailer_method, mailer_args, mailer_kwargs)
      expect(NotifyRateLimiterJob).to have_received(:perform_later).with(1.minute, anything, mailer, mailer_method, mailer_args, mailer_kwargs)
    end

    context "when mailer has additional arguments" do
      let(:mailer_args) { %w[arg1 arg2] }
      let(:mailer_kwargs) { { name: "Bob" } }

      it "passes additional arguments to NotifyRateLimiterJob" do
        described_class.call(collection:, mailer:, mailer_method:, mailer_args:, mailer_kwargs:)

        expect(NotifyRateLimiterJob).to have_received(:perform_later).with(0.minutes, anything, mailer, mailer_method, %w[arg1 arg2], { name: "Bob" })
        expect(NotifyRateLimiterJob).to have_received(:perform_later).with(1.minute, anything, mailer, mailer_method, %w[arg1 arg2], { name: "Bob" })
      end
    end
  end
end
