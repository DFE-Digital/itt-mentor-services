require "rails_helper"

RSpec.describe AccreditedProvider::Importer do
  subject { described_class.call }

  let(:existing_provider) { create(:provider) }

  before do
    next_year = Time.current.next_year.year

    stub_request(
      :get,
      "https://www.publish-teacher-training-courses.service.gov.uk/api/public/v1/recruitment_cycles/#{next_year}/providers?filter%5Bis_accredited_body%5D=true&per_page=500",
    ).to_return(
      status: 200,
      body: {
        "data" => [
          {
            "id" => 123,
            "attributes" => {
              "name" => "Provider 1",
              "code" => "Prov1",
              "provider_type" => "scitt",
            },
          },
          {
            "id" => 234,
            "attributes" => {
              "name" => "Provider 2",
              "code" => "Prov2",
              "provider_type" => "university",
            },
          },
          {
            "id" => 345,
            "attributes" => {
              "name" => "Provider 3",
              "code" => "Prov3",
              "provider_type" => "lead_school",
            },
          },
          {
            "id" => 456,
            "attributes" => {
              "code" => existing_provider.provider_code,
              "name" => existing_provider.name,
              "provider_type" => existing_provider.provider_type,
              "ukprn" => existing_provider.ukprn,
              "urn" => existing_provider.urn,
              "email" => existing_provider.email,
              "telephone" => existing_provider.telephone,
              "website" => existing_provider.website,
              "street_address_1" => existing_provider.street_address_1,
              "street_address_2" => existing_provider.street_address_2,
              "street_address_3" => existing_provider.street_address_3,
              "city" => existing_provider.city,
              "county" => existing_provider.county,
              "postcode" => existing_provider.postcode,
            },
          },
          {
            "id" => 567,
            "attributes" => {
              "name" => "Invalid Provider",
              "code" => "Inv",
              "provider_type" => nil,
            },
          },
        ],
      }.to_json,
    )
  end

  it "creates new provider records for responses which don't already exist or are valid" do
    expect { subject }.to change(Provider, :count).by(3)
    expect(Provider.find_by(name: "Provider 1", code: "Prov1", provider_type: "scitt")).to be_present
    expect(Provider.find_by(name: "Provider 2", code: "Prov2", provider_type: "university")).to be_present
    expect(Provider.find_by(name: "Provider 3", code: "Prov3", provider_type: "lead_school")).to be_present
    expect(Provider.find_by(name: "Invalid Provider", code: "Inv")).not_to be_present
    expect(Provider.where(name: existing_provider.name, code: existing_provider.provider_code).count).to eq(1)
  end
end
