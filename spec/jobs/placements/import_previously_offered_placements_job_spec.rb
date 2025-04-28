require "rails_helper"

RSpec.describe Placements::ImportPreviouslyOfferedPlacementsJob, type: :job do
  let!(:previously_offered_school) { create(:school, name: "Previously Offered School", urn: "123456") }
  let!(:never_offered_school) { create(:school, name: "Never Offered School", urn: "654321") }
  let(:csv_path) { "spec/fixtures/placements/previously_offered_placements.csv" }

  describe "#perform" do
    it "populates the schools table with previously offered placements" do
      described_class.perform_now(csv_path)

      expect(previously_offered_school.reload).to be_previously_offered_placements
      expect(never_offered_school.reload).not_to be_previously_offered_placements
    end

    it "does not raise an error if the CSV path is nil" do
      expect {
        described_class.perform_now(nil)
      }.not_to raise_error
    end
  end
end
