require "rails_helper"

RSpec.describe GovUk::BankHoliday do
  describe ".all" do
    let(:uri) { URI.parse(described_class::BASE_URI) }
    let(:http) { instance_double(Net::HTTP) }
    let(:request_uri) { uri.request_uri }

    before do
      allow(Net::HTTP::Get).to receive(:new).with(request_uri).and_call_original
    end

    context "when the request succeeds" do
      let(:response_body) do
        {
          "england-and-wales" => {
            "events" => [
              { "title" => "New Year's Day", "date" => "2026-01-01" },
            ],
          },
        }.to_json
      end
      let(:response) { instance_double(Net::HTTPSuccess, body: response_body) }

      before do
        allow(response).to receive(:is_a?).with(Net::HTTPSuccess).and_return(true)
        allow(Net::HTTP).to receive(:start)
          .with(uri.host, uri.port, use_ssl: true, verify_mode: OpenSSL::SSL::VERIFY_PEER)
          .and_yield(http)
        allow(http).to receive(:request).and_return(response)
      end

      it "returns the England and Wales bank holiday events" do
        expect(described_class.all).to eq([
          { "title" => "New Year's Day", "date" => "2026-01-01" },
        ])
      end
    end

    context "when the request fails" do
      let(:response) { instance_double(Net::HTTPServerError, code: "500") }

      before do
        allow(response).to receive(:is_a?).with(Net::HTTPSuccess).and_return(false)
        allow(Net::HTTP).to receive(:start)
          .with(uri.host, uri.port, use_ssl: true, verify_mode: OpenSSL::SSL::VERIFY_PEER)
          .and_yield(http)
        allow(http).to receive(:request).and_return(response)
      end

      it "raises a HTTP error" do
        expect { described_class.all }
          .to raise_error(Net::HTTPError, "Failed to fetch bank holidays: 500")
      end
    end
  end
end
