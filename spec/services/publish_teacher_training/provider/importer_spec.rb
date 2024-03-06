require "rails_helper"

RSpec.describe PublishTeacherTraining::Provider::Importer do
  subject(:importer) { described_class.call }

  context "with only providers in API response which don't exist" do
    before do
      non_existing_providers_request
    end

    it "creates new provider records for responses" do
      expect { importer }.to change(Provider, :count).by(3)
      expect(Provider.find_by(name: "Provider 1", code: "Prov1", provider_type: "scitt")).to be_present
      expect(Provider.find_by(name: "Provider 2", code: "Prov2", provider_type: "university")).to be_present
      expect(Provider.find_by(name: "Provider 3", code: "Prov3", provider_type: "lead_school")).to be_present
    end
  end

  context "with providers in API response which pre-exist" do
    let!(:existing_provider) { create(:provider) }
    let!(:changeable_provider) { create(:provider, name: "Changeable Provider") }

    before do
      pre_existing_providers_request
    end

    it "creates new provider records for responses which don't already exist or are valid,
      and updates any pre-existing providers" do
      expect { importer }.to change(Provider, :count).by(1)
      expect(Provider.find_by(name: "Provider 1", code: "Prov1", provider_type: "scitt")).to be_present
      expect(Provider.where(name: existing_provider.name, code: existing_provider.code).count).to eq(1)
      expect(Provider.find_by(code: changeable_provider.code).name).to eq("Changed Provider")
    end
  end

  context "with invalid providers in API response" do
    before do
      with_invalid_providers_request
    end

    it "creates new provider records for responses which don't already exist or are valid" do
      expect(Rails.logger).to receive(:info).with("Invalid Providers - [\"Provider with code Inv is invalid\"]")
      expect(Rails.logger).to receive(:info).with("Done!")
      expect { importer }.to change(Provider, :count).by(1)
      expect(Provider.find_by(name: "Provider 1", code: "Prov1", provider_type: "scitt")).to be_present
      expect(Provider.find_by(name: "Invalid Provider", code: "Inv")).not_to be_present
    end
  end

  context "with additional pages" do
    before do
      first_page_request
      second_page_request
    end

    it "iterates over the links in the API response to create records for providers across all pages" do
      expect { importer }.to change(Provider, :count).by(2)
      expect(Provider.find_by(name: "Page 1 Provider", code: "Pg1", provider_type: "scitt")).to be_present
      expect(Provider.find_by(name: "Page 2 Provider", code: "Pg2", provider_type: "scitt")).to be_present
    end
  end

  private

  def non_existing_providers_request
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
        ],
      }.to_json,
    )
  end

  def pre_existing_providers_request
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
        ],
      }.to_json,
    )
  end

  def with_invalid_providers_request
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
            "id" => 678,
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

  def first_page_request
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
              "name" => "Page 1 Provider",
              "code" => "Pg1",
              "provider_type" => "scitt",
            },
          },
        ],
        "links" => {
          "next" => "https://www.publish-teacher-training-courses.service.gov.uk/api/public/v1/recruitment_cycles/current/providers?page=2",
        },
      }.to_json,
    )
  end

  def second_page_request
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
end
