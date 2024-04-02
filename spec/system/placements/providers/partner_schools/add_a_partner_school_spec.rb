require "rails_helper"

RSpec.describe "Placements / Providers / Partner schools / Add a partner school",
               type: :system,
               service: :placements do
  let!(:school) { create(:placements_school, name: "School 1") }
  let(:provider) { create(:placements_provider, name: "Provider") }

  before do
    provider
    given_i_sign_in_as_patricia
  end

  scenario "User adds a partner school", js: true, retry: 3 do
    when_i_view_the_partner_schools_page
    and_i_click_on("Add partner school")
    and_i_enter_a_school_named("School 1")
    then_i_see_a_dropdown_item_for("School 1")
    when_i_click_the_dropdown_item_for("School 1")
    and_i_click_on("Continue")
    then_i_see_the_check_details_page_for_school("School 1")
    when_i_click_on("Add partner school")
    then_i_return_to_partner_school_index
    and_a_school_is_listed(school_name: "School 1")
    and_i_see_success_message
  end

  scenario "User adds a partner school which already exists", js: true, retry: 3 do
    given_a_partnership_exists_between(school, provider)
    when_i_view_the_partner_schools_page
    and_i_click_on("Add partner school")
    and_i_enter_a_school_named("School 1")
    then_i_see_a_dropdown_item_for("School 1")
    when_i_click_the_dropdown_item_for("School 1")
    and_i_click_on("Continue")
    then_i_see_an_error("School 1 has already been added. Try another school")
  end

  scenario "User submits the search form without selecting a school", js: true, retry: 3 do
    when_i_visit_the_add_partner_school_page
    and_i_click_on("Continue")
    then_i_see_an_error("Enter a school name, URN or postcode")
  end

  scenario "User reconsiders selecting a school", js: true, retry: 3 do
    given_i_have_completed_the_form_to_select(school:)
    when_i_click_on("Back")
    then_i_see_the_search_input_pre_filled_with("School 1")
    and_i_click_on("Continue")
    then_i_see_the_check_details_page_for_school("School 1")
  end

  private

  def given_i_sign_in_as_patricia
    user = create(:placements_user, :patricia)
    create(:user_membership, user:, organisation: provider)
    user_exists_in_dfe_sign_in(user:)
    visit sign_in_path
    click_on "Sign in using DfE Sign In"
  end

  def when_i_click_on(text)
    click_on text
  end
  alias_method :and_i_click_on, :when_i_click_on

  def when_i_view_the_partner_schools_page
    visit placements_provider_partner_schools_path(provider)

    expect_partner_schools_to_be_selected_in_primary_navigation
  end

  def and_i_enter_a_school_named(school_name)
    fill_in "partnership-school-id-field", with: school_name
  end

  def then_i_see_a_dropdown_item_for(school_name)
    expect(page).to have_css(".autocomplete__option", text: school_name)
  end

  def when_i_click_the_dropdown_item_for(school_name)
    page.find(".autocomplete__option", text: school_name).click
  end

  def then_i_see_the_check_details_page_for_school(school_name)
    expect(page).to have_css(".govuk-caption-l", text: "Add partner school")
    expect(page).to have_content("Check your answers")
    org_name_row = page.all(".govuk-summary-list__row")[0]
    expect(org_name_row).to have_content(school_name)
  end

  def then_i_return_to_partner_school_index
    expect(page.find(".govuk-heading-l")).to have_content("Partner schools")
  end

  def and_a_school_is_listed(school_name:)
    expect(page).to have_content(school_name)
  end

  def and_i_see_success_message
    expect(page).to have_content "Partner school added"
  end

  def given_a_partnership_exists_between(school, provider)
    create(:placements_partnership, school:, provider:)
  end
  alias_method :and_a_partnership_exists_between, :given_a_partnership_exists_between

  def then_i_see_an_error(error_message)
    # Error summary
    expect(page.find(".govuk-error-summary")).to have_content(
      "There is a problem",
    )
    expect(page.find(".govuk-error-summary")).to have_content(error_message)
    # Error above input
    expect(page.find(".govuk-error-message")).to have_content(error_message)
  end

  def when_i_visit_the_add_partner_school_page
    visit new_placements_provider_partner_school_path(provider)
  end

  def given_i_have_completed_the_form_to_select(school:)
    params = {
      "partnership" => { school_id: school.id, school_name: school.name },
      provider_id: provider.id,
    }
    visit check_placements_provider_partner_schools_path(params)
  end

  def then_i_see_the_search_input_pre_filled_with(school_name)
    within(".autocomplete__wrapper") do
      expect(page.find("#partnership-school-id-field").value).to eq(school_name)
    end
  end

  def expect_partner_schools_to_be_selected_in_primary_navigation
    nav = page.find(".app-primary-navigation__nav")

    within(nav) do
      expect(page).to have_link "Placements", current: "false"
      expect(page).to have_link "Partner schools", current: "page"
      expect(page).to have_link "Users", current: "false"
      expect(page).to have_link "Organisation details", current: "false"
    end
  end
end
