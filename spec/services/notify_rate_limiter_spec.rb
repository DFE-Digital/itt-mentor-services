require "rails_helper"

describe NotifyRateLimiter do
  let(:collection) { Claims::User.all }
  let(:mailer) { "Claims::UserMailer" }
  let(:mailer_method) { :claims_have_not_been_submitted }

  before do
    create_list(:claims_user, 150)

    allow(NotifyRateLimiterJob).to receive(:perform_later).with(0.minutes, anything, mailer:, mailer_method:)
    allow(NotifyRateLimiterJob).to receive(:perform_later).with(1.minute, anything, mailer:, mailer_method:)
  end

  it_behaves_like "a service object" do
    let(:params) { { collection:, mailer:, mailer_method: } }
  end

  describe "#call" do
    it "calls NotifyRateLimiterJob for each batch of users" do
      described_class.call(collection:, mailer:, mailer_method:)

      expect(NotifyRateLimiterJob).to have_received(:perform_later).with(0.minutes, anything, mailer:, mailer_method:)
      expect(NotifyRateLimiterJob).to have_received(:perform_later).with(1.minute, anything, mailer:, mailer_method:)
    end
  end
end
