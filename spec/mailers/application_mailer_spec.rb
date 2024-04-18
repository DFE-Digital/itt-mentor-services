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
end
