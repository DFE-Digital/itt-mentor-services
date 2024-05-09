require "rails_helper"

describe UpdateSchoolEmails do
  let(:csv_string) { "urn,name,,establishment status,closure date,email\n105287,Fairfield Community Primary School,,Open,31/03/24,Fairfield@bury.gov.uk\n40431,Yargen Primary School,,Open,31/03/24,YARGEN@bury.gov.uk\n,,,,,\n1234,No School,,Open,31/03/24,#N/A" }

  before do
    create(:claims_school, name: "Fairfield Community Primary School", region: regions(:inner_london), urn: "105287")
    create(:claims_school, name: "Yargen Primary School", region: regions(:inner_london), urn: "40431")
    create(:claims_school, name: "No School", region: regions(:inner_london), urn: "1234")
  end

  it_behaves_like "a service object" do
    let(:params) { { csv_string: } }
  end

  describe "#call" do
    it "updates the schools email_address field" do
      expect {
        described_class.call(csv_string:)
      }.to change { Claims::School.find_by(urn: "105287").email_address }.from(nil).to("fairfield@bury.gov.uk")
        .and change { Claims::School.find_by(urn: "40431").email_address }.from(nil).to("yargen@bury.gov.uk")
        .and(not_change { Claims::School.find_by(urn: "1234").email_address })
    end
  end
end
