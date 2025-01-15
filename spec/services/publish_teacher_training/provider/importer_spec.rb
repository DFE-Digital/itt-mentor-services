require "rails_helper"

RSpec.describe PublishTeacherTraining::Provider::Importer do
  subject(:importer) { described_class.call }

  it_behaves_like "a service object"

  context "with only providers in API response which don't exist" do
    before do
      non_existing_providers_request
    end

    it "creates new provider records for responses" do
      expect { importer }.to change(Provider, :count).by(3)
        .and change(ProviderEmailAddress, :count).by(2)
      expect(
        Provider.find_by(
          name: "Provider 1",
          code: "Prov1",
          provider_type: :scitt,
          email_address: "provider_1@example.com",
        ),
      ).to be_present
      expect(
        Provider.find_by(
          name: "Provider 2",
          code: "Prov2",
          provider_type: :university,
          email_address: nil,
        ),
      ).to be_present
      expect(
        Provider.find_by(
          name: "Provider 3",
          code: "Prov3",
          provider_type: :lead_school,
          email_address: "provider_3@example.com",
        ),
      ).to be_present
    end
  end

  context "with providers in API response which pre-exist" do
    let!(:existing_provider) { create(:provider, email_address: "existing_provider@example.com") }
    let(:existing_provider_email_address) do
      create(:provider_email_address, provider: existing_provider, email_address: "existing_provider@example.com")
    end
    let!(:changeable_provider) { create(:provider, name: "Changeable Provider") }

    before do
      existing_provider_email_address

      pre_existing_providers_request
    end

    it "creates new provider records for responses which don't already exist or are valid,
      and updates any pre-existing providers" do
      expect { importer }.to change(Provider, :count).by(1)
        .and change(ProviderEmailAddress, :count).by(2)
      new_provider = Provider.find_by(
        name: "Provider 1",
        code: "Prov1",
        provider_type: :scitt,
        email_address: "provider_1@example.com",
      )
      expect(new_provider).to be_present
      expect(
        ProviderEmailAddress.find_by(provider: new_provider, email_address: "provider_1@example.com"),
      ).to be_present
      expect(Provider.where(name: existing_provider.name, code: existing_provider.code).count).to eq(1)
      expect(changeable_provider.reload.name).to eq("Changed Provider")
      expect(changeable_provider.reload.email_address).to eq("changed_provider@example.com")
      expect(changeable_provider.email_addresses).to contain_exactly("changed_provider@example.com")
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
      expect(Provider.find_by(name: "Provider 1", code: "Prov1", provider_type: :scitt)).to be_present
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
      expect(Provider.find_by(name: "Page 1 Provider", code: "Pg1", provider_type: :scitt)).to be_present
      expect(Provider.find_by(name: "Page 2 Provider", code: "Pg2", provider_type: :scitt)).to be_present
    end
  end

  private

  def publish_url
    "https://www.publish-teacher-training-courses.service.gov.uk/api/public/v1/recruitment_cycles/current/providers"
  end

  def non_existing_providers_request
    stub_request(
      :get,
      publish_url,
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
              "email" => "provider_1@example.com",
            },
          },
          {
            "id" => 234,
            "attributes" => {
              "name" => "Provider 2",
              "code" => "Prov2",
              "provider_type" => "university",
              "email" => nil,
            },
          },
          {
            "id" => 345,
            "attributes" => {
              "name" => "Provider 3",
              "code" => "Prov3",
              "provider_type" => "lead_school",
              "email" => "provider_3@example.com",
            },
          },
        ],
      }.to_json,
    )
  end

  def pre_existing_providers_request
    stub_request(
      :get,
      publish_url,
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
              "email" => "provider_1@example.com",
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
              "email" => "changed_provider@example.com",
            },
          },
        ],
      }.to_json,
    )
  end

  def with_invalid_providers_request
    stub_request(
      :get,
      publish_url,
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
      publish_url,
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
          "next" => "#{publish_url}?page=2",
        },
      }.to_json,
    )
  end

  def second_page_request
    stub_request(
      :get,
      "#{publish_url}?page=2",
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
