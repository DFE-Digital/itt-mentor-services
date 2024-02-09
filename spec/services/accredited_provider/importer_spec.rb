require "rails_helper"

RSpec.describe Provider::Importer do
  subject(:importer) { described_class.call }

  let(:existing_provider) { create(:provider) }
  let(:changeable_provider) { create(:provider, name: "Changeable Provider") }

  before do
    stub_request(
      :get,
      "https://www.publish-teacher-training-courses.service.gov.uk/api/public/v1/recruitment_cycles/current/providers",
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
              "code" => existing_provider.code,
              "name" => existing_provider.name,
              "provider_type" => existing_provider.provider_type,
              "ukprn" => existing_provider.ukprn,
              "urn" => existing_provider.urn,
              "email" => existing_provider.email_address,
              "telephone" => existing_provider.telephone,
              "website" => existing_provider.website,
              "street_address_1" => existing_provider.address1,
              "street_address_2" => existing_provider.address2,
              "street_address_3" => existing_provider.address3,
              "city" => existing_provider.city,
              "county" => existing_provider.county,
              "postcode" => existing_provider.postcode,
              "accredited_body" => existing_provider.accredited,
            },
          },
          {
            "id" => 567,
            "attributes" => {
              "name" => "Changed Provider",
              "code" => changeable_provider.code,
              "provider_type" => changeable_provider.provider_type,
            },
          },
          {
            "id" => 678,
            "attributes" => {
              "name" => "Invalid Provider",
              "code" => "Inv",
              "provider_type" => nil,
            },
          },
        ],
        "links" => {
          "next" => "https://www.publish-teacher-training-courses.service.gov.uk/api/public/v1/recruitment_cycles/current/providers?page=2",
        },
      }.to_json,
    )

    stub_request(
      :get,
      "https://www.publish-teacher-training-courses.service.gov.uk/api/public/v1/recruitment_cycles/current/providers?page=2",
    ).to_return(
      status: 200,
      body: {
        "data" => [
          {
            "id" => 212,
            "attributes" => {
              "name" => "Page 2 Provider",
              "code" => "Pg2",
              "provider_type" => "scitt",
            },
          },
        ],
      }.to_json,
    )
  end

  it "creates new provider records for responses which don't already exist or are valid" do
    expect { importer }.to change(Provider, :count).by(4)
    expect(Provider.find_by(name: "Provider 1", code: "Prov1", provider_type: "scitt")).to be_present
    expect(Provider.find_by(name: "Provider 2", code: "Prov2", provider_type: "university")).to be_present
    expect(Provider.find_by(name: "Provider 3", code: "Prov3", provider_type: "lead_school")).to be_present
    expect(Provider.find_by(name: "Page 2 Provider", code: "Pg2", provider_type: "scitt")).to be_present
    expect(Provider.find_by(name: "Invalid Provider", code: "Inv")).not_to be_present
    expect(Provider.where(name: existing_provider.name, code: existing_provider.code).count).to eq(1)
    expect(Provider.find_by(code: changeable_provider.code).name).to eq("Changed Provider")
  end
end
