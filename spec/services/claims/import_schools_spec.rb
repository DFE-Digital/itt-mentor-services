require "rails_helper"

describe Claims::ImportSchools do
  before do
    create(:school, name: "Newton Farm Nursery, Infant and Junior School", region: regions(:inner_london), urn: "102181", claims_service: false)
    create(:school, name: "Adderley CofE Primary School", region: regions(:inner_london), urn: "123457", claims_service: false)
    create(:school, name: "Yeo Moor Primary School", region: regions(:inner_london), urn: "141361", claims_service: false)
  end

  it_behaves_like "a service object" do
    let(:params) { { csv_file_path: Rails.root.join("spec/fixtures/import_schools.csv") } }
  end

  describe "#call" do
    it "increases the number of claims schools by 3" do
      csv_file_path = Rails.root.join("spec/fixtures/import_schools.csv")

      expect { described_class.call(csv_file_path:) }.to change(Claims::School, :count).by(3)
    end
  end
end
