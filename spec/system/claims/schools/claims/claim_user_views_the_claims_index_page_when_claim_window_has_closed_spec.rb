require "rails_helper"

RSpec.describe "Claims user views the claims index page when claim window has closed", service: :claims, type: :system do
  scenario do
    given_an_eligible_school_exists_and_the_claim_window_is_closing
    and_i_am_signed_in
    then_i_see_the_claims_index_page_with_add_a_claim_button_and_no_claims
    and_i_see_an_inset_text_showing_claims_can_not_be_submitted
  end

  private

  def given_an_eligible_school_exists_and_the_claim_window_is_closing
    @user_anne = build(:claims_user, first_name: "Anne", last_name: "Wilson", email: "anne_wilson@education.gov.uk")
    @mentor =  build(:claims_mentor)
    @claim_window = build(:claim_window, :current, ends_on: 1.day.ago)
    @academic_year = @claim_window.academic_year
    @eligibility = build(:eligibility, claim_window: @claim_window, academic_year: @academic_year)
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
    expect(page).not_to have_link("Add claim", href: "/schools/#{@shelbyville_school.id}/claims/new")
    expect(page).to have_text("There are no claims for Shelbyville Elementary.")
  end

  def and_i_see_an_inset_text_showing_claims_can_not_be_submitted
    expect(page).to have_inset_text(
      "Claims can no longer be submitted for school year September #{@academic_year.starts_on.year} to July #{@academic_year.ends_on.year}.\n" \
      "You can still add a mentor. Final closing date for claims: #{I18n.l(@claim_window.ends_on.end_of_day, format: :time_on_date)}.",
    )
  end
end
