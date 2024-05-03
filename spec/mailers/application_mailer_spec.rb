require "rails_helper"

RSpec.describe ApplicationMailer, type: :mailer do
  describe "#protocol" do
    subject(:application_mailer) { described_class.new }

    context "when Rails environment is production" do
      before do
        allow(Rails).to receive(:env).and_return("production".inquiry)
      end

      it 'returns "https"' do
        expect(application_mailer.send(:protocol)).to eq("https")
      end
    end

    context "when Rails environment is not production" do
      before do
        allow(Rails).to receive(:env).and_return("development".inquiry)
      end

      it 'returns "http"' do
        expect(application_mailer.send(:protocol)).to eq("http")
      end
    end
  end

  describe "#host" do
    subject(:email) { example_mailer_class.with(service:).example_email }

    let(:example_mailer_class) do
      Class.new(ApplicationMailer) do
        def example_email
          mail(body: "host: #{host.inspect}")
        end
      end
    end

    let(:service) { nil }

    it "returns a 'nil' host" do
      expect(email.body).to eq("host: nil")
    end

    context "when given the 'claims' service" do
      let(:service) { "claims" }

      it "returns the CLAIMS_HOST" do
        expect(email.body).to eq("host: \"claims.localhost\"")
      end
    end

    context "when given the 'placements' service" do
      let(:service) { "placements" }

      it "returns the PLACEMENTS_HOST" do
        expect(email.body).to eq("host: \"placements.localhost\"")
      end
    end
  end
end
