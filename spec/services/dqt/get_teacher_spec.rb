require "rails_helper"

RSpec.describe Dqt::GetTeacher do
  context "with invalid trn" do
    subject(:get_teacher) { described_class.call(trn: "2222222") }

    before do
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

    it "raises error" do
      expect { get_teacher }.to raise_error(Dqt::Client::HttpError)
    end
  end

  context "with valid trn" do
    subject(:get_teacher) { described_class.call(trn: "1234567") }

    before do
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

    it "returns teacher details" do
      teacher = get_teacher
      expect(teacher).to match({
        "trn" => "1234567",
        "firstName" => "Judith",
        "middleName" => "",
        "lastName" => "Chicken",
        "dateOfBirth" => "1991-01-22",
        "nationalInsuranceNumber" => "B15J60R13",
        "email" => "anonymous@anonymousdomain.org.net.co.uk",
        "qts" => nil,
        "eyts" => nil,
      })
    end
  end
end
