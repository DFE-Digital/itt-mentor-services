require "rails_helper"

RSpec.describe Provider::Api do
  before do
    stub_request(
      :get,
      "https://www.publish-teacher-training-courses.service.gov.uk/api/public/v1/recruitment_cycles/2024/providers",
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

  subject { described_class.call }

  context "when the date is after between the first Tuesday in October (2023) and the end of the year" do
    it "returns a list of providers from the next recruitment cycle (2024) publish-teacher-training-courses api" do
      Timecop.freeze(Time.zone.local(2023, 10, 3, 1)) do # First Tuesday of October 2023
        response = subject
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
  end

  context "when the date is between the first day in the year (2024) and the first Tuesday in October (2024)" do
    it "returns a list of providers from the current recruitment cycle (2024) publish-teacher-training-courses api" do
      Timecop.freeze(Time.zone.local(2024, 1, 1, 1)) do
        response = subject
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
  end
end
