require "rails_helper"

RSpec.describe "Claims support user removes submitted claim", service: :claims, type: :system do
  scenario do
    given_an_eligible_school_exists_with_a_submitted_claim
    and_i_am_signed_in
    then_i_see_the_organisations_index_page

    when_i_click_on_shelbyville_elementary
    then_i_see_the_claims_index_page

    when_i_click_on_the_claim_reference
    then_i_see_the_claim_show_page

    when_i_click_on_remove_claim
    then_i_see_the_remove_claim_confirmation_page

    when_i_click_on_the_remove_claim_button
    then_i_see_the_claims_index_page_with_no_submitted_claims_and_a_success_banner
  end

  private

  def given_an_eligible_school_exists_with_a_submitted_claim
    @user_anne = build(:claims_user, first_name: "Anne", last_name: "Wilson")
    @mentor =  build(:claims_mentor, first_name: "James", last_name: "Jameson")
    @provider = build(:claims_provider, :best_practice_network)
    @claim_window = build(:claim_window, :current)
    @eligibility = build(:eligibility, claim_window: @claim_window)
    @date_completed = @claim_window.starts_on + 1.day
    @shelbyville_school = build(
      :claims_school,
      name: "Shelbyville Elementary",
      users: [@user_anne],
      eligibilities: [@eligibility],
      mentors: [@mentor],
    )
    @submitted_claim = create(:claim,
                              :submitted,
                              school: @shelbyville_school,
                              reference: "88888888",
                              provider: @provider,
                              claim_window: @claim_window)
  end

  def and_i_am_signed_in
    sign_in_claims_support_user
  end

  def then_i_see_the_organisations_index_page
    expect(page).to have_title("Organisations (2) - Claim funding for mentor training - GOV.UK")
    expect(page).to have_h1("Organisations (2)")
    within(".organisation-search-results") do
      expect(page).to have_link("Shelbyville Elementary")
    end
  end

  def when_i_click_on_shelbyville_elementary
    within(".organisation-search-results") do
      click_on "Shelbyville Elementary"
    end
  end

  def then_i_see_the_claims_index_page
    expect(page).to have_title("Claims - Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Claims")
    expect(page).to have_h1("Claims")
    expect(page).to have_link("Add claim", href: "/schools/#{@shelbyville_school.id}/claims/new")
  end

  def when_i_click_on_the_claim_reference
    click_on "88888888"
  end

  def then_i_see_the_claim_show_page
    expect(page).to have_title("Claim - 88888888 - Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Claims")
    expect(page).to have_h1("Claim - 88888888")
    expect(page).to have_tag("Submitted", "turquoise")
    expect(page).to have_h2("Details")
    expect(page).to have_summary_list_row("School", "Shelbyville Elementary")
    expect(page).to have_summary_list_row("Academic year", @claim_window.academic_year.name.to_s)
    expect(page).to have_summary_list_row("Accredited provider", "Best Practice Network")
    expect(page).to have_link("Remove claim")
  end

  def when_i_click_on_remove_claim
    click_on "Remove claim"
  end

  def then_i_see_the_remove_claim_confirmation_page
    expect(page).to have_title("Are you sure you want to remove this claim? - Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Claims")
    expect(page).to have_h1("Are you sure you want to remove this claim?")

    expect(page).to have_button("Remove claim")
    expect(page).to have_link("Cancel")
  end

  def when_i_click_on_the_remove_claim_button
    click_button "Remove claim"
  end

  def then_i_see_the_claim_removal_success_page
    expect(page).to have_title("Claims - Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Claims")
    expect(page).to have_h1("Claims")

    expect(page).to have_button("Remove claim")
    expect(page).to have_link("Cancel")
  end

  def then_i_see_the_claims_index_page_with_no_submitted_claims_and_a_success_banner
    expect(page).to have_title("Claims - Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Claims")
    expect(page).to have_h1("Claims")
    expect(page).to have_link("Add claim", href: "/schools/#{@shelbyville_school.id}/claims/new")
    expect(page).to have_text("There are no claims for Shelbyville Elementary.")
    expect(page).to have_success_banner("Claim has been removed")
  end
end
