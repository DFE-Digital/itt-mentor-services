require "rails_helper"

RSpec.describe Geocoder::UpdateAllSchools do
  subject(:geocode_all_schools) { described_class.call }

  let!(:uxbridge_school) do
    create(:school, name: "Uxbridge School", postcode: "UB8 1SB", town: "London")
  end
  let!(:brixton_school) do
    create(:school, name: "York School", town: "York", postcode: "YO1 8SG")
  end

  context "when no schools have been geocoded" do
    before do
      uxbridge_school.update!(longitude: nil, latitude: nil)
      brixton_school.update!(longitude: nil, latitude: nil)
    end

    it "updates the longitude and latitude of all schools" do
      expect { geocode_all_schools }.to change { uxbridge_school.reload.longitude }.from(nil)
        .and change { uxbridge_school.reload.latitude }.from(nil)
        .and change { brixton_school.reload.longitude }.from(nil)
        .and change { brixton_school.reload.latitude }.from(nil)
        .and change { School.geocoded.count }.to(2)
    end
  end

  context "when some schools have been geocoded" do
    before do
      uxbridge_school.update!(longitude: nil, latitude: nil)
    end

    it "updates the longitude and latitude of not geocoded schools" do
      expect { geocode_all_schools }.to change { uxbridge_school.reload.longitude }.from(nil)
        .and change { uxbridge_school.reload.latitude }.from(nil)
        .and change { School.geocoded.count }.to(2)
    end

    it "does not update the longitude of geocoded schools" do
      expect { geocode_all_schools }.not_to(change { brixton_school.reload.longitude })
    end

    it "does not update the latitude of geocoded schools" do
      expect { geocode_all_schools }.not_to(change { brixton_school.reload.latitude })
    end
  end
end
