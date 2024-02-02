require "rails_helper"

RSpec.describe "View a schools claims", type: :system, service: :claims do
  let!(:school) { create(:school, :claims).becomes(Claims::School) }
  let!(:another_school) { create(:school, :claims).becomes(Claims::School) }

  let!(:colin) { create(:claims_support_user, :colin) }

  let!(:submitted_claim) { create(:claim, school_id: school.id, draft: false) }
  let!(:draft_claim) { create(:claim, school_id: school.id, draft: true) }
  let!(:claim_from_another_school) { create(:claim, school_id: another_school.id, draft: true) }

  scenario "View a school's claims as a support user" do
    user_exists_in_dfe_sign_in(user: colin)
    given_i_sign_in
    when_i_visit_the_claims_support_school_claims_page
    i_see_a_list_of_the_schools_claims
    i_dont_see_claims_from_other_schools
  end

  private

  def given_i_sign_in
    visit sign_in_path
    click_on "Sign in using DfE Sign In"
  end

  def when_i_visit_the_claims_support_school_claims_page
    visit claims_support_school_claims_path(school)
  end

  def i_see_a_list_of_the_schools_claims
    expect(page).to have_content("#{draft_claim.id}\nDraft\n#{submitted_claim.id}\nSubmitted")
  end

  def i_dont_see_claims_from_other_schools
    expect(page).not_to have_content("#{claim_from_another_school.id}\nDraft")
  end
end
