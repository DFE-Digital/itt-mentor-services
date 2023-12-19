require "rails_helper"

RSpec.describe AccreditedProviderApi do
  before do
    next_year = Time.current.next_year.year

    stub_request(
      :get,
      "https://www.publish-teacher-training-courses.service.gov.uk/api/public/v1/recruitment_cycles/#{next_year}/providers?filter%5Bis_accredited_body%5D=true",
    ).to_return(
      status: 200,
      body: {
        "data" => [
          {
            "id" => 123,
            "attributes" => {
              name: "Provider 1",
              code: "Prov1",
            },
          },
          {
            "id" => 234,
            "attributes" => {
              name: "Provider 2",
              code: "Prov2",
            },
          },
        ],
      }.to_json,
    )

    stub_request(
      :get,
      "https://www.publish-teacher-training-courses.service.gov.uk/api/public/v1/recruitment_cycles/#{next_year}/providers/Prov1",
    ).to_return(
      status: 200,
      body: {
        "data" => {
          "id" => 123,
          "attributes" => {
            name: "Provider 1",
            code: "Prov1",
          },
        },
      }.to_json,
    )
  end

  context "when not given a code" do
    subject { described_class.call }

    it "returns a list of providers from the publish-teacher-training-courses api" do
      response = subject
      expect(response).to match_array(
        [
          {
            "id" => 123,
            "attributes" => {
              "name" => "Provider 1",
              "code" => "Prov1",
            },
          },
          {
            "id" => 234,
            "attributes" => {
              "name" => "Provider 2",
              "code" => "Prov2",
            },
          },
        ],
      )
    end
  end

  context "when given a code" do
    subject { described_class.call("Prov1") }

    it "returns details for a provider matching that code" do
      response = subject
      expect(response).to eq(
        {
          "id" => 123,
          "attributes" => {
            "name" => "Provider 1",
            "code" => "Prov1",
          },
        },
      )
    end
  end
end
