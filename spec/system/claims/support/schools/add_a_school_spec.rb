require "rails_helper"

RSpec.describe "Support User adds a School", service: :claims, type: :system do
  let(:school) { create(:school, name: "School 1") }
  let(:current_claim_window) { create(:claim_window, :current).decorate }
  let(:upcoming_claim_window) { create(:claim_window, :upcoming).decorate }

  before do
    school
    upcoming_claim_window
    current_claim_window
    given_i_sign_in_as_colin
  end

  after { Capybara.app_host = nil }

  scenario "Colin adds a new School", :js do
    when_i_visit_the_add_school_page
    and_i_enter_a_school_named("School 1")
    then_i_see_a_dropdown_item_for("School 1")
    when_i_click_the_dropdown_item_for("School 1")
    and_i_click_continue
    then_i_see_the_claim_window_page

    when_i_select_the_current_claim_window
    and_click_on_continue
    then_i_see_the_check_details_page_for_school("School 1")
    i_then_click_change_school_link
    and_i_click_continue
    when_i_click_save_organisation
    then_i_return_to_support_organisations_index
    and_a_school_is_listed(school_name: "School 1")
    and_i_see_success_message
  end

  scenario "Colin adds a school which already exists", :js do
    given_a_school_already_exists_for_claims
    when_i_visit_the_add_school_page
    and_i_enter_a_school_named("Claims School")
    then_i_see_a_dropdown_item_for("Claims School")
    when_i_click_the_dropdown_item_for("Claims School")
    and_i_click_continue
    then_i_see_an_error("Claims School has already been added. Try another school")
  end

  scenario "Colin submits the search form without selecting a school", :js do
    when_i_visit_the_add_school_page
    and_i_click_continue
    then_i_see_an_error("Enter a school name, unique reference number (URN) or postcode")
  end

  scenario "Colin reconsiders onboarding a school", :js do
    when_i_visit_the_add_school_page
    and_i_enter_a_school_named("School 1")
    then_i_see_a_dropdown_item_for("School 1")
    when_i_click_the_dropdown_item_for("School 1")
    and_i_click_continue
    then_i_see_the_claim_window_page

    when_i_select_the_current_claim_window
    and_click_on_continue
    then_i_see_the_check_details_page_for_school("School 1")
    when_i_click_back
    and_i_click_back
    then_i_see_the_search_input_pre_filled_with("School 1")
    and_i_click_continue
    and_i_click_continue
    then_i_see_the_check_details_page_for_school("School 1")
  end

  private

  def i_then_click_change_school_link
    click_on "Change Organisation name"
    expect(page).to have_content("Enter a school name, URN or postcode")
    click_on "Continue"
  end

  def and_there_is_an_existing_user_for(user_name)
    user = create(:claims_support_user, user_name.downcase.to_sym)
    user_exists_in_dfe_sign_in(user:)
  end

  def given_i_sign_in_as_colin
    and_there_is_an_existing_user_for("Colin")
    visit sign_in_path
    click_on "Sign in using DfE Sign In"
  end

  def when_i_visit_the_add_school_page
    visit new_add_school_claims_support_schools_path
  end

  def and_i_enter_a_school_named(school_name)
    fill_in "claims-add-school-wizard-school-step-id-field", with: school_name
  end

  def then_i_see_a_dropdown_item_for(school_name)
    expect(page).to have_css(".autocomplete__option", text: school_name, wait: 10)
  end

  def when_i_click_the_dropdown_item_for(school_name)
    page.find(".autocomplete__option", text: school_name).click
  end

  def and_i_click_continue
    click_on "Continue"
  end

  def when_i_click_back
    click_on "Back"
  end
  alias_method :and_i_click_back, :when_i_click_back

  def then_i_see_the_check_details_page_for_school(school_name)
    expect(page).to have_css(".govuk-caption-l", text: "Add organisation")
    expect(page).to have_content("Check your answers")
    expect(page).to have_summary_list_row("Claim window", current_claim_window.name)
    expect(page).to have_summary_list_row("Organisation name", school_name)
  end

  def when_i_click_save_organisation
    click_on "Save organisation"
  end

  def then_i_return_to_support_organisations_index
    expect(page).to have_content("Organisations")
  end

  def given_a_school_already_exists_for_claims
    create(:school, :claims, name: "Claims School")
  end

  def then_i_see_an_error(error_message)
    expect(page.find(".govuk-error-summary")).to have_content(
      "There is a problem",
    )
    expect(page.find(".govuk-error-summary")).to have_content(error_message)
    expect(page.find(".govuk-error-message")).to have_content(error_message)
  end

  def and_a_school_is_listed(school_name:)
    expect(page).to have_content(school_name)
  end

  def and_i_see_success_message
    expect(page).to have_content "Organisation added"
  end

  def given_i_have_completed_the_form_to_onboard(school:)
    params = { school: { id: school.id, name: school.name } }
    visit check_claims_support_schools_path(params)
  end

  def then_i_see_the_search_input_pre_filled_with(school_name)
    within(".autocomplete__wrapper") do
      expect(page.find("#claims-add-school-wizard-school-step-id-field").value).to eq(school_name)
    end
  end

  def then_i_see_the_claim_window_page
    expect(page).to have_title("Select a claim window - Add organisation")
    expect(page).to have_element(:span, text: "Add organisation", class: "govuk-caption-l")
    expect(page).to have_element(:h1, text: "Select a claim window", class: "govuk-fieldset__heading")

    expect(page).to have_field(current_claim_window.name, type: :radio, visible: :all)
    expect(page).to have_field(upcoming_claim_window.name, type: :radio, visible: :all)
  end

  def when_i_select_the_current_claim_window
    choose current_claim_window.name
  end

  def and_click_on_continue
    click_on "Continue"
  end
end
