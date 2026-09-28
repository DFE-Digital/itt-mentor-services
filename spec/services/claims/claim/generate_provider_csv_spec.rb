require "rails_helper"

RSpec.describe Claims::Claim::GenerateProviderCSV do
  subject(:generate_provider_csv) { described_class.call(claims: Claims::Claim.all) }

  let(:provider) { create(:claims_provider, name: "Best Practice Network") }
  let(:historic_claim_window) { create(:claim_window, :historic) }
  let(:current_claim_window) { create(:claim_window, :current) }
  let(:hogwarts) { create(:claims_school, name: "Hogwarts", urn: "111111") }
  let(:springfield) { create(:claims_school, name: "Springfield Elementary", urn: "222222") }
  let(:barry) { create(:claims_mentor, first_name: "Barry", last_name: "Garlow") }
  let(:sarah) { create(:claims_mentor, first_name: "Sarah", last_name: "Doe") }

  before do
    current_claim = create(:claim, :submitted, provider:, school: springfield, claim_window: current_claim_window, reference: "22222222")
    create(:mentor_training, claim: current_claim, mentor: barry, hours_completed: 10, hours_clawed_back: 4)

    historic_claim = create(:claim, :submitted, provider:, school: hogwarts, claim_window: historic_claim_window, reference: "11111111")
    create(:mentor_training, claim: historic_claim, mentor: barry, hours_completed: 20)
    create(:mentor_training, claim: historic_claim, mentor: sarah, hours_completed: 6)
  end

  it_behaves_like "a service object" do
    let(:params) { { claims: Claims::Claim.all } }
  end

  it "returns a row per mentor training, ordered by academic year, school and claim reference" do
    historic_year = historic_claim_window.academic_year_name
    current_year = current_claim_window.academic_year_name

    expect(generate_provider_csv.lines.first.chomp).to eq(
      "academic_year,school_urn,school_name,claim_reference,mentor_first_name,mentor_last_name,hours_claimed,provider_name",
    )
    expect(generate_provider_csv.lines.drop(1).map(&:chomp)).to contain_exactly(
      "#{historic_year},111111,Hogwarts,11111111,Barry,Garlow,20,Best Practice Network",
      "#{historic_year},111111,Hogwarts,11111111,Sarah,Doe,6,Best Practice Network",
      "#{current_year},222222,Springfield Elementary,22222222,Barry,Garlow,6,Best Practice Network",
    )
    expect(generate_provider_csv.lines.last).to start_with(current_year)
  end
end
