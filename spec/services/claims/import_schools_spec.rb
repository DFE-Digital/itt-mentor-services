require "rails_helper"

describe Claims::ImportSchools do
  before do
    region = create(:region, name: "Inner London", claims_funding_available_per_hour: Money.from_amount(53.60, "GBP"))
    create(:school, name: "Newton Farm Nursery, Infant and Junior School", region:, urn: "102181", claims_service: false)
    create(:school, name: "Adderley CofE Primary School", region:, urn: "123457", claims_service: false)
    create(:school, name: "Yeo Moor Primary School", region:, urn: "141361", claims_service: false)
  end

  describe "#call" do
    it "increases the number of claims schools by 3" do
      csv_file_path = Rails.root.join("spec/fixtures/import_schools.csv")

      expect { described_class.call(csv_file_path:) }.to change(Claims::School, :count).by(3)
    end
  end
end
