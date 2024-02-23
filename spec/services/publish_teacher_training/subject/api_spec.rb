require "rails_helper"

RSpec.describe PublishTeacherTraining::Subject::Api do
  before do
    success_stub_request
  end

  describe ".call" do
    it "returns the API data from the Publish Subject Area endpoint" do
      expect(described_class.call).to eq(response_body)
    end
  end

  def success_stub_request
    stub_request(
      :get,
      "https://www.publish-teacher-training-courses.service.gov.uk/api/public/v1/subject_areas?include=subjects",
    ).to_return(
      status: 200,
      body: response_body.to_json,
    )
  end

  def response_body
    {
      "data" => [
        {
          "id" => "PrimarySubject",
          "relationships" => {
            "subjects" => {
              "data" => [
                {
                  "type" => "subjects",
                  "id" => "1",
                },
                {
                  "type" => "subjects",
                  "id" => "2",
                },
              ],
            },
          },
        },
        {
          "id" => "SecondarySubject",
          "relationships" => {
            "subjects" => {
              "data" => [
                {
                  "type" => "subjects",
                  "id" => "3",
                },
                {
                  "type" => "subjects",
                  "id" => "4",
                },
              ],
            },
          },
        },
        {
          "id" => "ModernLanguagesSubject",
          "relationships" => {
            "subjects" => {
              "data" => [
                {
                  "type" => "subjects",
                  "id" => "5",
                },
              ],
            },
          },
        },
      ],
      "included" => [
        {
          "id" => "1",
          "attributes" => {
            "name" => "Primary",
            "code" => "00",
          },
        },
        {
          "id" => "2",
          "attributes" => {
            "name" => "Primary with English",
            "code" => "01",
          },
        },
        {
          "id" => "3",
          "attributes" => {
            "name" => "Art and design",
            "code" => "W1",
          },
        },
        {
          "id" => "4",
          "type" => "subjects",
          "attributes" => {
            "name" => "Science",
            "code" => "F0",
          },
        },
        {
          "id" => "5",
          "attributes" => {
            "name" => "French",
            "code" => "15",
          },
        },
      ],
    }
  end
end
