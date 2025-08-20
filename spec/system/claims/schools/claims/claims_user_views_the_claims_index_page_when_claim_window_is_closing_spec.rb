require "rails_helper"

RSpec.describe "Claims user views the claims index page when claim window is closing", service: :claims, type: :system do
  scenario do
    given_an_eligible_school_exists_and_the_claim_window_is_closing
    and_i_am_signed_in
    then_i_see_the_claims_index_page_with_add_a_claim_button_and_no_claims
  end

  private

  def given_an_eligible_school_exists_and_the_claim_window_is_closing
    @user_anne = build(:claims_user, first_name: "Anne", last_name: "Wilson", email: "anne_wilson@education.gov.uk")
    @mentor =  build(:claims_mentor)
    @claim_window = build(:claim_window, :current, ends_on: 1.day.from_now)
    @eligibility = build(:eligibility, claim_window: @claim_window)
    @shelbyville_school = create(
      :claims_school,
      name: "Shelbyville Elementary",
      users: [@user_anne],
      eligibilities: [@eligibility],
      mentors: [@mentor],
    )
  end

  def and_i_am_signed_in
    sign_in_as(@user_anne)
  end

  def then_i_see_the_claims_index_page_with_add_a_claim_button_and_no_claims
    expect(page).to have_title("Claims - Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Claims")
    expect(page).to have_important_banner("There is 1 day remaining to claim for ITT general mentor training before the claim window closes.")
    expect(page).to have_h1("Claims")
    expect(page).to have_link("Add claim", href: "/schools/#{@shelbyville_school.id}/claims/new")
    expect(page).to have_text("There are no claims for Shelbyville Elementary.")
  end
end
