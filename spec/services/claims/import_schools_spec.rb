require "rails_helper"

describe Claims::ImportSchools do
  let(:csv_string) { "provider_name,placement_school_urn,placement_school_name,First name,Last name,Email\nBest Practice Network,40435,Yeo Moor Primary School,Bob,Yargen,bob1@gmail.com\nBest Practice Network,40431,Yargen Primary School,Bob,Yargen,bob2@gmail.com\nBest Practice Network,40432,Bob Primary School,Bob,Yargen,bob3@gmail.com\nBest Practice Network,40439,another Primary School,#N/A,#N/A,#N/A" }

  before do
    create(:school, name: "Yeo Moor Primary School", region: regions(:inner_london), urn: "40435", claims_service: false)
    create(:school, name: "Yargen Primary School", region: regions(:inner_london), urn: "40431", claims_service: false)
    create(:school, name: "Bob Primary School", region: regions(:inner_london), urn: "40432", claims_service: false)
    create(:school, name: "another Primary School", region: regions(:inner_london), urn: "40439", claims_service: false)
  end

  it_behaves_like "a service object" do
    let(:params) { { csv_string: } }
  end

  describe "#call" do
    it "increases the number of schools schools by 4, users by 3, and user_memberships by 3" do
      expect {
        described_class.call(csv_string:)
      }.to change(Claims::School, :count).by(4)
       .and change(Claims::User, :count).by(3)
       .and change(UserMembership, :count).by(3)
    end
  end
end
