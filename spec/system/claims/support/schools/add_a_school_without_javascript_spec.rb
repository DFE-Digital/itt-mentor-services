require "rails_helper"

RSpec.describe "Support User adds a School without JavaScript", service: :claims, type: :system do
  before do
    create(:school, name: "Manchester 1")
    create(:school, name: "Manchester 2")
    create(:school, name: "London")

    given_i_sign_in_as_colin
  end

  scenario "Colin adds a new School" do
    when_i_visit_the_add_school_page
    and_i_enter_a_school_named("Manch")
    and_i_click_continue
    then_i_see_list_of_schools
    then_i_choose("Manchester 1")
    and_i_click_continue
    then_i_see_the_check_details_page_for_school("Manchester 1")
    when_i_click_save_organisation
    then_i_return_to_support_organisations_index
    and_a_school_is_listed(school_name: "Manchester 1")
  end

  scenario "Colin adds a school which already exists" do
    given_a_school_already_exists_for_claims
    when_i_visit_the_add_school_page
    and_i_enter_a_school_named("Manch")
    and_i_click_continue
    then_i_see_list_of_schools
    then_i_choose("Manchester 1")
    and_i_click_continue
    then_i_see_an_error("Manchester 1 has already been added. Try another school")
  end

  scenario "Colin submits the search form without selecting a school" do
    when_i_visit_the_add_school_page
    and_i_click_continue
    then_i_see_an_error("Enter a school name, unique reference number (URN) or postcode")
  end

  scenario "Colin submits the options form without selecting a school" do
    when_i_visit_the_add_school_page
    and_i_enter_a_school_named("Manch")
    and_i_click_continue
    then_i_see_list_of_schools
    and_i_click_continue
    then_i_see_an_error("Select a school")
  end

  scenario "Colin reconsiders onboarding a school" do
    when_i_visit_the_add_school_page
    and_i_enter_a_school_named("Manch")
    and_i_click_continue
    then_i_see_list_of_schools
    then_i_choose("Manchester 1")
    and_i_click_continue
    then_i_see_the_check_details_page_for_school("Manchester 1")
    when_i_click_back
    and_the_option_for_school_has_been_pre_selected("Manchester 1")
    when_i_click_back
    then_i_see_the_search_input_pre_filled_with("Manch")
    and_i_click_continue
    then_i_see_list_of_schools
    then_i_choose("Manchester 1")
    and_i_click_continue
    then_i_see_the_check_details_page_for_school("Manchester 1")
  end

  private

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

  def and_i_click_continue
    click_on "Continue"
  end

  def when_i_click_back
    click_on "Back"
  end

  def then_i_see_list_of_schools
    expect(page).to have_content("Manchester 1")
    expect(page).to have_content("Manchester 2")
    expect(page).not_to have_content("London")
  end

  def then_i_choose(selection_name)
    choose selection_name
  end

  def then_i_see_the_check_details_page_for_school(school_name)
    expect(page).to have_content("Manchester 1")
    expect(page).to have_content("Check your answers")
    org_name_row = page.all(".govuk-summary-list__row")[0]
    expect(org_name_row).to have_content(school_name)
  end

  def when_i_click_save_organisation
    click_on "Save organisation"
  end

  def then_i_return_to_support_organisations_index
    expect(page).to have_content("Organisations")
  end

  def given_a_school_already_exists_for_claims
    School.find_by_name("Manchester 1").update!(claims_service: true)
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

  def given_i_have_completed_the_form_to_onboard(school_name)
    school = School.find_by(name: school_name)
    params = { school: { id: school.id, name: school.name } }
    visit check_claims_support_schools_path(params)
  end

  def then_i_see_the_search_input_pre_filled_with(school_name)
    expect(page.find("#claims-add-school-wizard-school-step-id-field").value).to eq(school_name)
  end

  def and_the_option_for_school_has_been_pre_selected(school_name)
    expect(page).to have_checked_field(school_name)
  end
end
