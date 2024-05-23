require "rails_helper"

RSpec.describe PublishTeacherTraining::Subject::Import do
  include ActiveJob::TestHelper

  before do
    success_stub_request
  end

  it_behaves_like "a service object"

  describe ".call" do
    context "when the response contains only valid subject data" do
      it "creates a subject for each valid subject in the API response" do
        expect {
          described_class.call
        }.to change(Subject.primary, :count).by(2).and change(
          Subject.secondary, :count
        ).by(4)

        expect(Subject.primary.pluck(:name)).to match_array([
          "Primary", "Primary with English"
        ])

        expect(Subject.secondary.pluck(:name)).to match_array([
          "Art and design", "Science", "French", "Modern Languages"
        ])

        modern_languages = Subject.find_by(name: "Modern Languages")
        expect(modern_languages.child_subjects.pluck(:name)).to match_array(
          %w[French],
        )
      end

      context "when a subject already exists" do
        it "only creates a subject for each not pre-existing subject" do
          create(:subject, :primary, name: "Primary", code: "00")

          expect {
            described_class.call
          }.to change(Subject, :count).by(5)
        end
      end
    end

    context "when the response contains an invalid subject data" do
      before do
        failure_stub_request
      end

      it "only creates a the valid subject" do
        allow(Sentry).to receive(:capture_exception)

        expect { described_class.call }.to change(Subject.primary, :count).by(1)

        expect(Subject.primary.pluck(:name)).to contain_exactly("Primary with English")
        expect(Sentry).to have_received(:capture_exception)
      end
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

  def failure_stub_request
    stub_request(
      :get,
      "https://www.publish-teacher-training-courses.service.gov.uk/api/public/v1/subject_areas?include=subjects",
    ).to_return(
      status: 200,
      body: invalid_response_body.to_json,
    )
  end

  def invalid_response_body
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
      ],
      "included" => [
        {
          "id" => "1",
          "attributes" => {
            "name" => "",
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
      ],
    }
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
                {
                  "type" => "subjects",
                  "id" => "7",
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
          "id" => "7",
          "type" => "subjects",
          "attributes" => {
            "name" => "Modern Languages",
            "code" => nil,
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
