require "rails_helper"

RSpec.describe PublishTeacherTraining::Provider::SyncAllJob, type: :job do
  describe "#perform" do
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
                "name" => "Provider 1",
                "code" => "Prov1",
                "provider_type" => "scitt",
              },
            },
          ],
        }.to_json,
      )
    end

    it "calls the PublishTeacherTraining::Provider::Importer service" do
      expect(PublishTeacherTraining::Provider::Importer).to receive(:call)
      described_class.perform_now
    end
  end
end
