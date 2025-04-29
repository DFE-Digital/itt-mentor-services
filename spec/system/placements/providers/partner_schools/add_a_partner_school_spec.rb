require "rails_helper"

RSpec.describe "Placements / Providers / Partner schools / Add a partner school",
               service: :placements, type: :system do
  include ActiveJob::TestHelper

  around do |example|
    perform_enqueued_jobs { example.run }
  end

  let!(:school) { create(:school, :placements, name: "School 1") }
  let(:provider) { create(:placements_provider, name: "Provider") }

  before do
    given_i_am_signed_in_as_a_placements_user(organisations: [provider])
  end

  scenario "User adds a partner school", :js do
    when_i_view_the_partner_schools_page
    and_i_click_on("Add school")
    and_i_enter_a_school_named("School 1")
    then_i_see_a_dropdown_item_for("School 1")
    when_i_click_the_dropdown_item_for("School 1")
    and_i_click_on("Continue")
    then_i_see_the_check_details_page_for_school("School 1")
    when_i_click_on("Confirm and add school")
    then_i_return_to_partner_school_index
    and_a_school_is_listed(school_name: "School 1")
    and_i_see_success_message
  end

  scenario "User adds a partner school which already exists", :js do
    given_a_partnership_exists_between(school, provider)
    when_i_view_the_partner_schools_page
    and_i_click_on("Add school")
    and_i_enter_a_school_named("School 1")
    then_i_see_a_dropdown_item_for("School 1")
    when_i_click_the_dropdown_item_for("School 1")
    and_i_click_on("Continue")
    then_i_see_an_error("School 1 has already been added. Try another school")
  end

  scenario "User submits the search form without selecting a school", :js do
    when_i_visit_the_add_partner_school_page
    and_i_click_on("Continue")
    then_i_see_an_error("Enter a school name, unique reference number (URN) or postcode")
  end

  scenario "User reconsiders selecting a school using back link", :js do
    when_i_view_the_partner_schools_page
    and_i_click_on("Add school")
    and_i_enter_a_school_named("School 1")
    then_i_see_a_dropdown_item_for("School 1")
    when_i_click_the_dropdown_item_for("School 1")
    and_i_click_on("Continue")
    then_i_see_the_check_details_page_for_school("School 1")
    when_i_click_on("Back")
    then_i_see_the_search_input_pre_filled_with("School 1")
    and_i_click_on("Continue")
    then_i_see_the_check_details_page_for_school("School 1")
  end

  scenario "User reconsiders selecting a school using change link", :js do
    when_i_view_the_partner_schools_page
    and_i_click_on("Add school")
    and_i_enter_a_school_named("School 1")
    then_i_see_a_dropdown_item_for("School 1")
    when_i_click_the_dropdown_item_for("School 1")
    and_i_click_on("Continue")
    then_i_see_the_check_details_page_for_school("School 1")
    when_i_click_on("Change Name")
    then_i_see_the_search_input_pre_filled_with("School 1")
    and_i_click_on("Continue")
    then_i_see_the_check_details_page_for_school("School 1")
  end

  scenario "User adds a partner school, which is not onboarded on the placements service", :js do
    given_the_school_is_not_onboarded_on_placements_service(school)
    when_i_view_the_partner_schools_page
    and_i_click_on("Add school")
    and_i_enter_a_school_named("School 1")
    then_i_see_a_dropdown_item_for("School 1")
    when_i_click_the_dropdown_item_for("School 1")
    and_i_click_on("Continue")
    then_i_see_the_check_details_page_for_school("School 1")
    when_i_click_on("Confirm and add school")
    then_i_return_to_partner_school_index
    and_a_school_is_listed(school_name: "School 1")
    and_i_see_success_message
  end

  describe "when I use multiple tabs to add partner schools", :js do
    let(:school_2) { create(:school, :placements, name: "School 2") }
    let(:windows) do
      {
        open_new_window => { school: },
        open_new_window => { school: school_2 },
      }
    end

    it "persists the school details for each tab upon refresh" do
      windows.each do |window, details|
        within_window window do
          when_i_view_the_partner_schools_page
          and_i_click_on("Add school")
          and_i_enter_a_school_named(details[:school].name)
          then_i_see_a_dropdown_item_for(details[:school].name)
          when_i_click_the_dropdown_item_for(details[:school].name)
          and_i_click_on("Continue")
          then_i_see_the_check_details_page_for_school(details[:school].name)
        end
      end

      # We need this test to be A -> B -> A -> B, so we can't combine the loops.
      # rubocop:disable Style/CombinableLoops
      windows.each do |window, details|
        within_window window do
          when_i_refresh_the_page
          then_the_school_details_have_not_changed(details[:school].name)
          when_i_click_on("Confirm and add school")
          then_i_return_to_partner_school_index
          and_a_school_is_listed(school_name: details[:school].name)
          and_i_see_success_message
        end
      end
      # rubocop:enable Style/CombinableLoops

      when_i_view_the_partner_schools_page
      then_i_see_my_schools(windows.values)
    end
  end

  private

  def when_i_click_on(text)
    click_on text
  end
  alias_method :and_i_click_on, :when_i_click_on

  def when_i_view_the_partner_schools_page
    visit placements_provider_partner_schools_path(provider)

    expect_partner_schools_to_be_selected_in_primary_navigation
  end

  def and_i_enter_a_school_named(school_name)
    fill_in "Add a school", with: school_name
  end

  def then_i_see_a_dropdown_item_for(school_name)
    expect(page).to have_css(".autocomplete__option", text: school_name, wait: 10)
  end

  def when_i_click_the_dropdown_item_for(school_name)
    page.find(".autocomplete__option", text: school_name).click
  end

  def then_i_see_the_check_details_page_for_school(school_name)
    expect(page).to have_content("Confirm school details")
    org_name_row = page.all(".govuk-summary-list__row")[0]
    expect(org_name_row).to have_content(school_name)
  end

  def then_i_return_to_partner_school_index
    expect(page.find(".govuk-heading-l")).to have_content("Schools you work with")
  end

  def and_a_school_is_listed(school_name:)
    expect(page).to have_content(school_name)
  end

  def and_i_see_success_message
    expect(page).to have_content "School added"
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
    visit new_add_partner_school_placements_provider_partner_schools_path(provider)
  end

  def then_i_see_the_search_input_pre_filled_with(school_name)
    within(".autocomplete__wrapper") do
      find_field "Add a school", with: school_name
    end
  end

  def expect_partner_schools_to_be_selected_in_primary_navigation
    nav = page.find(".app-primary-navigation__nav")

    within(nav) do
      expect(page).to have_link "Find", current: "false"
      expect(page).to have_link "My placements", current: "false"
      expect(page).to have_link "Schools", current: "page"
      expect(page).to have_link "Users", current: "false"
      expect(page).to have_link "Organisation details", current: "false"
    end
  end

  def given_the_school_is_not_onboarded_on_placements_service(school)
    school.update!(placements_service: false)
  end

  def when_i_refresh_the_page
    visit current_path
  end

  def then_i_see_my_schools(schools)
    schools.each do |school|
      expect(page).to have_content(school[:school].name)
    end
  end

  alias_method :then_the_school_details_have_not_changed, :then_i_see_the_check_details_page_for_school
end
