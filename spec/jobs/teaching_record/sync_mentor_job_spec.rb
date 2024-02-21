require "rails_helper"

RSpec.describe TeachingRecord::SyncMentorJob, type: :job do
  describe "#perform" do
    context "when the mentor has a valid trn" do
      let!(:mentor) { create(:mentor, first_name: "Joe", last_name: "Bloggs", trn: "1234567") }

      before do
        success_stub_request
      end

      it "updates the mentors first_name and last_name attributes" do
        expect { described_class.perform_now(mentor) }.to change {
          mentor.reload.first_name
        }.from("Joe").to("Judith").and change {
          mentor.reload.last_name
        }.from("Bloggs").to("Chicken")
      end
    end

    context "when the mentor has an invalid trn" do
      let!(:mentor) { create(:mentor, first_name: "Joe", last_name: "Bloggs", trn: "2222222") }

      before do
        failure_stub_request
      end

      it "does not update the mentors first name" do
        expect { described_class.perform_now(mentor) }.not_to change {
          mentor.reload.first_name
        }.from("Joe")
      end

      it "does not update the mentors last name" do
        expect { described_class.perform_now(mentor) }.not_to change {
          mentor.reload.last_name
        }.from("Bloggs")
      end

      it "sends an error to sentry" do
        allow(Sentry).to receive(:capture_exception)
        described_class.perform_now(mentor)
        expect(Sentry).to have_received(:capture_exception)
      end
    end

    context "when the request returns an unhandled error" do
      let!(:mentor) { create(:mentor, first_name: "Joe", last_name: "Bloggs", trn: "3333333") }

      before do
        unhandled_stub_request
      end

      it "raises an error" do
        expect { described_class.perform_now(mentor) }.to raise_error(
          TeachingRecord::RestClient::HttpError,
        )
      end
    end
  end

  def success_stub_request
    stub_request(:get, "https://preprod.teacher-qualifications-api.education.gov.uk/v3/teachers/1234567")
      .with(
        headers: {
          "Accept" => "application/json",
          "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
          "Authorization" => "Bearer secret",
          "Content-Type" => "application/json;odata.metadata=minimal",
          "User-Agent" => "Ruby",
          "X-Api-Version" => "20240101",
        },
      )
      .to_return(
        status: 200,
        body: "{\"trn\":\"1234567\",\"firstName\":\"Judith\",\"middleName\":\"\",\"lastName\":\"Chicken\",\"dateOfBirth\":\"1991-01-22\",\"nationalInsuranceNumber\":\"B15J60R13\",\"email\":\"anonymous@anonymousdomain.org.net.co.uk\",\"qts\":null,\"eyts\":null}",
        headers: {},
      )
  end

  def failure_stub_request
    stub_request(:get, "https://preprod.teacher-qualifications-api.education.gov.uk/v3/teachers/2222222")
      .with(
        headers: {
          "Accept" => "application/json",
          "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
          "Authorization" => "Bearer secret",
          "Content-Type" => "application/json;odata.metadata=minimal",
          "User-Agent" => "Ruby",
          "X-Api-Version" => "20240101",
        },
      )
      .to_return(
        status: 404,
        body: "{\"type\":\"https://tools.ietf.org/html/rfc9110#section-15.5.5\",\"title\":\"Not Found\",\"status\":404,\"traceId\":\"00-dff9d2243466591e882b480c8bdbfc27-f60a1ced105d1602-00\"}",
        headers: {},
      )
  end

  def unhandled_stub_request
    stub_request(:get, "https://preprod.teacher-qualifications-api.education.gov.uk/v3/teachers/3333333")
      .with(
        headers: {
          "Accept" => "application/json",
          "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
          "Authorization" => "Bearer secret",
          "Content-Type" => "application/json;odata.metadata=minimal",
          "User-Agent" => "Ruby",
          "X-Api-Version" => "20240101",
        },
      )
      .to_return(
        status: 500,
        body: "{\"type\":\"https://tools.ietf.org/html/rfc9110#section-15.5.5\",\"title\":\"Not Found\",\"status\":404,\"traceId\":\"00-dff9d2243466591e882b480c8bdbfc27-f60a1ced105d1602-00\"}",
        headers: {},
      )
  end
end
