require "rails_helper"

RSpec.describe Geocoder::UpdateAllSchoolsJob, type: :job do
  describe "#perform" do
    it "calls the Geocoder::UpdateAllSchools service" do
      expect(Geocoder::UpdateAllSchools).to receive(:call)
      described_class.perform_now
    end
  end
end
