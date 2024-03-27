require "rails_helper"

RSpec.describe Providers::SyncApplicants do
  subject(:sync_applicants) { described_class.call }

  let(:applicant_data) do
    { "data" => [
      {
        "attributes" => {
          "course" => {
            "training_provider_code" => "ABC",
          },
          "candidate" => {
            "id" => "123",
            "first_name" => "John",
            "last_name" => "Doe",
          },
          "contact_details" => {
            "email" => "jane.doe@example.com",
            "address_line1" => "123 Fake Street",
            "address_line2" => "Fake Town",
            "address_line3" => "Fake County",
            "address_line4" => "Fake Country",
            "postcode" => "AB1 2CD",
          },
        },
      },
    ] }
  end
  let(:provider) { create(:provider, code: "ABC") }
  let(:provider2) { create(:provider, code: "DEF") }

  before do
    allow(Apply::Register::Application::Api).to receive(:call)
      .and_return(applicant_data)
  end

  it_behaves_like "a service object"

  describe "#call" do
    context "when the applicant matches the provider" do
      it "creates a new applicant for the provider", :aggregate_failures do
        provider
        provider2
        sync_applicants
        expect(provider.applicants.count).to eq(1)
        expect(provider2.applicants.count).to eq(0)
      end
    end

    context "when the applicant matches no providers" do
      it "does not create an applicant" do
        provider2
        sync_applicants
        expect(Applicant.count).to eq(0)
      end
    end
  end
end
