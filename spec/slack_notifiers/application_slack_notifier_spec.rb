require "rails_helper"

RSpec.describe ApplicationSlackNotifier do
  describe "#default_url_options" do
    context "when service is :claims" do
      subject(:claims_slack_notifier_class) do
        Class.new(described_class) do
          self.service = :claims

          def root_url_notification
            message(text: claims_root_url)
          end
        end
      end

      it "builds claims urls" do
        expect(claims_slack_notifier_class.root_url_notification.text).to eq("http://claims.localhost/")
      end
    end

    context "when service is :placements" do
      subject(:placements_slack_notifier_class) do
        Class.new(described_class) do
          self.service = :placements

          def root_url_notification
            message(text: placements_root_url)
          end
        end
      end

      it "builds placements urls" do
        expect(placements_slack_notifier_class.root_url_notification.text).to eq("http://placements.localhost/")
      end
    end

    context "when service is not provided" do
      subject(:unknown_service_slack_notifier_class) do
        Class.new(described_class) do
          def sign_in_notification
            message(text: sign_in_url)
          end
        end
      end

      it "builds placements urls" do
        expect { unknown_service_slack_notifier_class.sign_in_notification }.to raise_error(
          ArgumentError,
          "Missing host to link to! Please provide the :host parameter, set default_url_options[:host], or set :only_path to true",
        )
      end
    end
  end
end
