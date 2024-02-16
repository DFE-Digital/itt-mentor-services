require "rails_helper"

RSpec.describe "View claims", type: :system, service: :claims do
  let!(:school) { create(:claims_school) }
  let!(:anne) do
    create(
      :claims_user,
      :anne,
      user_memberships: [create(:user_membership, organisation: school)],
    )
  end

  before do
    user_exists_in_dfe_sign_in(user: anne)
    given_i_sign_in
  end

  scenario "Anne visits the claims index page" do
    when_i_visit_claim_index_page
    i_see_a_list_of_the_schools_claims
  end

  private

  def when_i_visit_claim_index_page
    click_on("Claims")
  end

  def i_see_a_list_of_the_schools_claims
    school.claims.each_with_index do |_, index|
      expect(page).to have_content("Claim #{index + 1}")
    end
  end

  def given_i_sign_in
    visit sign_in_path
    click_on "Sign in using DfE Sign In"
  end
end
