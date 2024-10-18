require "rails_helper"

RSpec.describe "Placements / Support / Organisations / Support User Selects An Organisation Type To Add",
               service: :placements, type: :system do
  before do
    given_i_am_signed_in_as_a_placements_support_user
  end

  scenario "Colin selects to add an ITT provider" do
    when_i_click_add_organisation
    then_i_see_support_navigation_with_organisation_selected
    when_i_select_the_radio_option("Teacher training provider")
    and_i_click_on("Continue")
    then_i_see_the_title("Enter a provider name, United Kingdom provider number (UKPRN), unique reference number (URN) or postcode")
  end

  scenario "Colin selects to add a school" do
    when_i_click_add_organisation
    then_i_see_support_navigation_with_organisation_selected
    when_i_select_the_radio_option("School")
    and_i_click_on("Continue")
    then_i_see_the_title("Enter a school name, unique reference number (URN) or postcode")
  end

  scenario "Colin doesn't select an organisation type" do
    when_i_click_add_organisation
    then_i_see_support_navigation_with_organisation_selected
    and_i_click_on("Continue")
    then_i_see_an_error("Select an organisation type")
  end

  describe "when I use multiple tabs to add organisations", :js do
    let(:coop_academy_leeds) { create(:school, name: "Co-op Academy Leeds", urn: "137065") }
    let(:kings_college_london) { create(:school, name: "King's College London", urn: "133874") }
    let(:windows) do
      {
        open_new_window => { name: coop_academy_leeds.name, urn: coop_academy_leeds.urn },
        open_new_window => { name: kings_college_london.name, urn: kings_college_london.urn },
      }
    end

    it "persists the mentor details for each tab upon refresh" do
      windows.each do |window, details|
        within_window window do
          given_i_navigate_to_the_organisations_list
          when_i_click_add_organisation
          then_i_see_support_navigation_with_organisation_selected
          when_i_select_the_radio_option("School")
          and_i_click_on("Continue")
          then_i_see_the_title("Enter a school name, unique reference number (URN) or postcode")
          and_i_enter_a_school_named(details[:name])
          then_i_see_a_dropdown_item_for(details[:name])
          when_i_click_the_dropdown_item_for(details[:name])
          and_i_click_on("Continue")
        end
      end

      # We need this test to be A -> B -> A -> B, so we can't combine the loops.
      # rubocop:disable Style/CombinableLoops
      windows.each do |window, details|
        within_window window do
          when_i_refresh_the_page
          then_the_selected_school_has_not_changed(details[:name], details[:urn])
          and_i_click_on("Add organisation")
          then_the_organisation_is_added(details[:name])
        end
      end
      # rubocop:enable Style/CombinableLoops

      given_i_navigate_to_the_organisations_list
      then_i_see_my_organisations(windows.values)
    end
  end

  private

  def given_i_navigate_to_the_organisations_list
    visit placements_support_organisations_path
  end

  def and_i_click_on(text)
    click_on text
  end

  def when_i_click_add_organisation
    click_on "Add organisation"
  end

  def then_i_see_support_navigation_with_organisation_selected
    within(".govuk-header__navigation-list") do
      expect(page).to have_link "Organisations"
      expect(page).to have_link "Support users"
    end
  end

  def when_i_select_the_radio_option(organisation_type)
    choose(organisation_type)
  end

  def then_i_see_the_title(title_text)
    expect(page.find(".govuk-label--l")).to have_content(title_text)
  end

  def then_i_see_an_error(error_message)
    expect(page.find(".govuk-error-summary")).to have_content(
      "There is a problem",
    )
    expect(page.find(".govuk-error-summary")).to have_content(error_message)
  end

  def and_i_enter_a_school_named(school_name)
    fill_in "Enter a school name, unique reference number (URN) or postcode", with: school_name
  end

  def then_i_see_a_dropdown_item_for(school_name)
    expect(page).to have_css(".autocomplete__option", text: school_name)
  end

  def when_i_click_the_dropdown_item_for(school_name)
    page.find(".autocomplete__option", text: school_name).click
  end

  def when_i_refresh_the_page
    visit current_path
  end

  def then_the_selected_school_has_not_changed(name, urn)
    within "#organisation-details" do
      expect(page).to have_content(name)
      expect(page).to have_content(urn)
    end
  end

  def then_the_organisation_is_added(name)
    within(".govuk-notification-banner--success") do
      expect(page).to have_content "Organisation added"
    end
    expect(page).to have_content name
  end

  def then_i_see_my_organisations(organisations)
    organisations.each do |organisation|
      expect(page).to have_content organisation[:name]
    end
  end
end
