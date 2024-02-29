require "rails_helper"

RSpec.describe "Download claims CSV", type: :system, service: :claims do
  let(:support_user) { create(:claims_support_user) }

  before do
    create_claim
    user_exists_in_dfe_sign_in(user: support_user)
    given_i_sign_in
  end

  scenario "Support user visits the claims index page and downloads CSV" do
    given_i_am_on_the_claims_index_page
    when_i_click_download_claims
    then_i_receive_a_csv_file
  end

  private

  def given_i_sign_in
    visit sign_in_path
    click_on "Sign in using DfE Sign In"
  end

  def given_i_am_on_the_claims_index_page
    click_on("Claims")
  end

  def when_i_click_download_claims
    click_on("Download claims")
  end

  def then_i_receive_a_csv_file
    expect(response_headers["Content-Type"]).to eq "text/csv"
  end

  def create_claim
    region = create(:region, name: "Inner London", claims_funding_available_per_hour: Money.from_amount(53.60, "GBP"))
    school = create(:claims_school, :claims, name: "School name 1", region_id: region.id, urn: "1234")

    create(:claim, school_id: school.id, reference: "12345678")
  end
end
