require "rails_helper"

RSpec.describe SlackNotifier do
  let(:example_slack_notifier_class) do
    Class.new(described_class) do
      def text_message
        message(text: "Hello, World!")
      end
    end
  end

  describe ".method_missing" do
    context "when instance method is defined in subclass" do
      subject(:method_missing_call) { example_slack_notifier_class.text_message }

      it "returns a SlackNotifier::Message instance" do
        expect(method_missing_call).to be_a(SlackNotifier::Message)
        expect(method_missing_call).to have_attributes(text: "Hello, World!")
      end
    end

    context "when instance method is not defined in subclass" do
      subject(:method_missing_call) { example_slack_notifier_class.message }

      it "raises a NoMethodError" do
        expect { method_missing_call }.to raise_error(NoMethodError)
      end
    end
  end

  describe SlackNotifier::Message do
    subject(:example_message) { described_class.new(endpoint_url:, text: "Hello, World!") }

    describe "#deliver_now" do
      subject(:deliver_now_call) { example_message.deliver_now }

      context "when endpoint_url is present" do
        let(:endpoint_url) { "https://hooks.slack.com/services/secret" }

        before do
          stub_slack_post_request
        end

        it "performs a HTTP post call to the provided endpoint_url" do
          expect(HTTParty).to receive(:post).with(endpoint_url, body: "{\"text\":\"Hello, World!\",\"blocks\":null}")

          deliver_now_call
        end
      end

      context "when endpoint_url is nil" do
        let(:endpoint_url) { nil }

        it "does nothing" do
          expect(deliver_now_call).to be_nil
        end
      end
    end

    describe "#deliver_later" do
      subject(:deliver_later_call) { example_message.deliver_later }

      let(:endpoint_url) { "https://hooks.slack.com/services/secret" }

      it "enqueues a SlackNotifier::Message::DeliveryJob" do
        expect { deliver_later_call }.to have_enqueued_job(SlackNotifier::Message::DeliveryJob).with(endpoint_url, "Hello, World!", nil)
      end
    end

    describe SlackNotifier::Message::DeliveryJob do
      subject(:example_delivery_job) { described_class.new }

      describe "#perform" do
        subject(:perform_call) { example_delivery_job.perform(endpoint_url, "Hello, World!", nil) }

        let(:endpoint_url) { "https://hooks.slack.com/services/secret" }

        before do
          stub_slack_post_request
        end

        it "builds an instance of Message with its given arguments and call perform_now on the message" do
          message = instance_double(SlackNotifier::Message, deliver_now: nil)

          allow(SlackNotifier::Message).to receive(:new).with(endpoint_url:, text: "Hello, World!", blocks: nil).and_return(message)

          perform_call

          expect(message).to have_received(:deliver_now)
        end
      end
    end
  end

  private

  def stub_slack_post_request
    stub_request(:post, "https://hooks.slack.com/services/secret")
      .with(body: "{\"text\":\"Hello, World!\",\"blocks\":null}")
      .to_return(status: 200, body: "ok")
  end
end
