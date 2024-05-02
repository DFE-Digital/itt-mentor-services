require "rails_helper"

RSpec.describe "Placements / Support / Schools / Support User adds a School",
               type: :system, service: :placements do
  let(:school) { create(:school, name: "School 1") }

  before do
    school
    given_i_sign_in_as_colin
  end

  after { Capybara.app_host = nil }

  scenario "Colin adds a new School", js: true, retry: 3 do
    when_i_visit_the_add_school_page
    and_i_enter_a_school_named("School 1")
    then_i_see_a_dropdown_item_for("School 1")
    when_i_click_the_dropdown_item_for("School 1")
    and_i_click_continue
    then_i_see_the_check_details_page_for_school("School 1")
    when_i_click_add_organisation
    then_i_return_to_support_organisations_index
    and_a_school_is_listed(school_name: "School 1")
    and_i_see_success_message
  end

  scenario "Colin adds a school which already exists", js: true, retry: 3 do
    given_a_school_already_exists_for_placements
    when_i_visit_the_add_school_page
    and_i_enter_a_school_named("Placements School")
    then_i_see_a_dropdown_item_for("Placements School")
    when_i_click_the_dropdown_item_for("Placements School")
    and_i_click_continue
    then_i_see_an_error("Placements School has already been added. Try another school")
  end

  scenario "Colin submits the search form without selecting a school", js: true, retry: 3 do
    when_i_visit_the_add_school_page
    and_i_click_continue
    then_i_see_an_error("Enter a school name, URN or postcode")
  end

  scenario "Colin reconsiders onboarding a school", js: true, retry: 3 do
    given_i_have_completed_the_form_to_onboard(school:)
    when_i_click_back
    then_i_see_the_search_input_pre_filled_with("School 1")
    and_i_click_continue
    then_i_see_the_check_details_page_for_school("School 1")
  end

  private

  def and_there_is_an_existing_user_for(user_name)
    user = create(:placements_support_user, user_name.downcase.to_sym)
    user_exists_in_dfe_sign_in(user:)
  end

  def and_i_visit_the_sign_in_path
    visit sign_in_path
  end

  def and_i_click_sign_in
    click_on "Start now"
  end

  def given_i_sign_in_as_colin
    and_there_is_an_existing_user_for("Colin")
    and_i_visit_the_sign_in_path
    and_i_click_sign_in
  end

  def when_i_visit_the_add_school_page
    visit new_placements_support_school_path
  end

  def and_i_enter_a_school_named(school_name)
    fill_in "school-id-field", with: school_name
  end

  def then_i_see_a_dropdown_item_for(school_name)
    expect(page).to have_css(".autocomplete__option", text: school_name)
  end

  def when_i_click_the_dropdown_item_for(school_name)
    page.find(".autocomplete__option", text: school_name).click
  end

  def and_i_click_continue
    click_on "Continue"
  end

  def then_i_see_the_check_details_page_for_school(school_name)
    expect(page).to have_css(".govuk-caption-l", text: "Add organisation")
    expect(page).to have_content("Check your answers")
    org_name_row = page.all(".govuk-summary-list__row")[0]
    expect(org_name_row).to have_content(school_name)
  end

  def when_i_click_add_organisation
    click_on "Add organisation"
  end

  def when_i_click_back
    click_on "Back"
  end

  def then_i_return_to_support_organisations_index
    expect(page).to have_content("Organisations")
  end

  def given_a_school_already_exists_for_placements
    create(:school, :placements, name: "Placements School")
  end

  def then_i_see_an_error(error_message)
    # Error summary
    expect(page.find(".govuk-error-summary")).to have_content(
      "There is a problem",
    )
    expect(page.find(".govuk-error-summary")).to have_content(error_message)
    # Error above input
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
    visit check_placements_support_schools_path(params)
  end

  def then_i_see_the_search_input_pre_filled_with(school_name)
    within(".autocomplete__wrapper") do
      expect(page.find("#school-id-field").value).to eq(school_name)
    end
  end
end
