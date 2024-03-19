require "rails_helper"

RSpec.describe PublishTeacherTraining::Provider::Api do
  subject(:provider_api) { described_class.call }

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
  end

  it_behaves_like "a service object" do
    let(:params) { {} }
  end

  it "returns a list of providers from the current recruitment cycle publish-teacher-training-courses api" do
    response = provider_api
    expect(response.fetch("data")).to match_array(
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
