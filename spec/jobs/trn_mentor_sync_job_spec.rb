require "rails_helper"

RSpec.describe TRNMentorSyncJob, type: :job do
  subject(:job) { described_class.perform_now }

  describe "#perform" do
    context "when a valid mentor exists" do
      let(:mentor) do
        create(:placements_mentor,
               first_name: "Jane",
               last_name: "Doe",
               trn: "1234567")
      end

      before do
        success_stub_request
        mentor
      end

      it "updates the mentor's details" do
        expect { job }.to change { mentor.reload.first_name }.from("Jane").to("Judith")
          .and change { mentor.reload.last_name }.from("Doe").to("Chicken")
      end
    end

    context "when an invalid mentor exists" do
      let(:mentor) do
        create(:placements_mentor,
               first_name: "Jane",
               last_name: "Doe",
               trn: "2222222")
      end

      before do
        failure_stub_request
        mentor
      end

      it "does not update the mentor's first name" do
        expect { job }.not_to change { mentor.reload.first_name }.from("Jane")
      end

      it "does not update the mentor's last name" do
        expect { job }.not_to change { mentor.reload.last_name }.from("Doe")
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
end
