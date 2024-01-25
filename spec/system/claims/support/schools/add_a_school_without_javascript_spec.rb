require "rails_helper"

RSpec.describe "Support User adds a School without JavaScript", type: :system, service: :claims do
  let!(:schools) do
    [
      create(:school, name: "Manchester 1"),
      create(:school, name: "Manchester 2"),
      create(:school, name: "London"),
    ]
  end

  before do
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
    when_i_click_add_organisation
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
    then_i_see_an_error("Enter a school name, URN or postcode")
  end

  scenario "Colin submits the options form without selecting a school" do
    when_i_visit_the_add_school_page
    and_i_enter_a_school_named("Manch")
    and_i_click_continue
    then_i_see_list_of_schools
    and_i_click_continue
    then_i_see_an_error("Select a school")
  end

  private

  def and_there_is_an_existing_persona_for(persona_name)
    create(:claims_support_user, persona_name.downcase.to_sym)
  end

  def and_i_visit_the_personas_page
    visit personas_path
  end

  def and_i_click_sign_in_as(persona_name)
    click_on "Sign In as #{persona_name}"
  end

  def given_i_sign_in_as_colin
    and_there_is_an_existing_persona_for("Colin")
    and_i_visit_the_personas_page
    and_i_click_sign_in_as("Colin")
  end

  def when_i_visit_the_add_school_page
    visit new_claims_support_school_path
  end

  def and_i_enter_a_school_named(school_name)
    fill_in "school-id-field", with: school_name
  end

  def and_i_click_continue
    click_on "Continue"
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

  def when_i_click_add_organisation
    click_on "Add organisation"
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
end
