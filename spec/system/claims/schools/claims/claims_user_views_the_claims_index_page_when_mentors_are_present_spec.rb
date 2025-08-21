require "rails_helper"

RSpec.describe "Claims user views the claims index page when mentors are present", service: :claims, type: :system do
  scenario do
    given_an_eligible_school_exists_with_a_mentor_and_no_claims
    and_i_am_signed_in
    then_i_see_the_claims_index_page_with_add_a_claim_button_and_no_claims
  end

  private

  def given_an_eligible_school_exists_with_a_mentor_and_no_claims
    @user_anne = build(:claims_user, first_name: "Anne", last_name: "Wilson", email: "anne_wilson@education.gov.uk")
    @mentor =  build(:claims_mentor)
    @claim_window = create(:claim_window, :current)
    @eligibility = build(:eligibility, academic_year: @claim_window.academic_year)
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
    expect(page).to have_h1("Claims")
    expect(page).to have_link("Add claim", href: "/schools/#{@shelbyville_school.id}/claims/new")
    expect(page).to have_text(
      "There are no claims for Shelbyville Elementary.",
    )
  end
end
