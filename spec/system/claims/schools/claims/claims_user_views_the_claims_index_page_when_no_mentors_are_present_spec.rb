require "rails_helper"

RSpec.describe "Claims user views the claims index page when no mentors are present", service: :claims, type: :system do
  scenario do
    given_an_eligible_school_exists_with_no_mentors_or_internal_draft_claims
    and_i_am_signed_in
    then_i_see_the_claims_index_page_with_add_mentor_guidance_and_no_internal_draft_claims
    and_i_can_see_the_no_records_message
  end

  private

  def given_an_eligible_school_exists_with_no_mentors_or_internal_draft_claims
    @user_anne = build(:claims_user, first_name: "Anne", last_name: "Wilson", email: "anne_wilson@education.gov.uk")
    @claim_window = create(:claim_window, :current)
    @eligibility = build(:eligibility, academic_year: @claim_window.academic_year)
    @shelbyville_school = create(
      :claims_school,
      name: "Shelbyville Elementary",
      users: [@user_anne],
      eligibilities: [@eligibility],
    )
  end

  def and_i_am_signed_in
    sign_in_as(@user_anne)
  end

  def then_i_see_the_claims_index_page_with_add_mentor_guidance_and_no_internal_draft_claims
    expect(page).to have_title("Claims - Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Claims")
    expect(page).to have_h1("Claims")
    within(".govuk-inset-text") do
      expect(page).to have_text(
        "Before you can start a claim you will need to add a mentor.",
      )
      expect(page).to have_link("add a mentor", href: "/schools/#{@shelbyville_school.id}/mentors")
    end
    expect(page).to have_text(
      "There are no claims for Shelbyville Elementary.",
    )
  end

  def i_do_not_see_any_internal_draft_claims
    expect(page).to have_text("There are no claims for #{school.name}")
  end

  def and_i_can_see_the_no_records_message
    expect(page).to have_text(
      "There are no claims for Shelbyville Elementary.",
    )
  end
end
