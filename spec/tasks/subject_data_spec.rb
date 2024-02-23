require "rails_helper"
require "rake"

describe "subject_data" do
  Rails.application.load_tasks if Rake::Task.tasks.empty?

  describe "import" do
    subject(:import) { Rake::Task["subject_data:import"].invoke }

    before do
      success_stub_request
    end

    it "runs the PublishTeacherTraining::Subject::Import service, creating a subject
      per valid subject in the Publish API" do
      expect { import }.to change(Subject.primary, :count).by(2).and change(
        Subject.secondary, :count
      ).by(3)
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
        {
          # FurtherEducationSubject is not a valid subject area
          "id" => "FurtherEducationSubject",
          "relationships" => {
            "subjects" => {
              "data" => [
                {
                  "type" => "subjects",
                  "id" => "6",
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
        {
          # Further education is not a valid subject
          "id" => "6",
          "attributes" => {
            "name" => "Further education",
            "code" => "41",
          },
        },
      ],
    }
  end
end
