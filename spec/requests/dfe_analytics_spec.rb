require "rails_helper"
require "dfe/analytics/rspec/matchers"

RSpec.describe "DfE Analytics integration", type: :request do
  before do
    # DfE Analytics is usually disabled in tests
    # Switch it on just for these tests
    allow(DfE::Analytics).to receive(:enabled?).and_return(true)
  end

  describe "requests to the app" do
    it "sends a web_request event to dfe-analytics" do
      expect { get "/" }.to have_sent_analytics_event_types(:web_request)
    end
  end

  describe "requests to the healthcheck endpoint" do
    it "does not send the request to dfe-analytics" do
      expect { get "/healthcheck" }.not_to have_sent_analytics_event_types(:web_request)
    end
  end
end
