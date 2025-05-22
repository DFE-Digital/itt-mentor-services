require "rails_helper"

RSpec.describe "Placements / Providers / Partner schools / Views a partner school",
               service: :placements, type: :system do
  scenario do
    given_multiple_schools_exist_and_a_provider_exists_with_schools_assigned
    given_a_school_exists_that_is_not_assigned_to_the_provider
    given_i_am_signed_in

    when_i_navigate_to_the_provider_schools_page
    then_i_see_the_provider_schools_index_with_
  end

  private

  def given_multiple_schools_exist_and_a_provider_exists_with_schools_assigned
    @user_anne = build(:placements_user, first_name: "Anne", last_name: "Wilson", email: "anne_wilson@education.gov.uk")
    @provider = create(:placements_provider, users: [@user_anne])
    @shelbyville_school = build(
      :placements_school,
      name: "Shelbyville Elementary",
    )
    @sandbrook_school = build(
      :placements_school,
      name: "Shelbyville Elementary",
    )
  end

  def given_a_school_exists_that_is_not_assigned_to_the_provider; end

  def given_i_am_signed_in
    sign_in_as(@user_anne)
  end

  def when_i_navigate_to_the_provider_schools_page
    within(".app-primary-navigation") do
      click_on "Schools"
    end
  end

  def then_i_see_the_provider_schools_index_with_no_schools
    expect(page).to have_title("Schools you work with - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Schools")
    expect(page).to have_h1("Schools you work with")
    expect(page).to have_text("View all placements your schools have published.")
    expect(page).to have_text("Only schools you work with are able to assign you their placements.")
    expect(page).to have_link("Add school")
    expect(page).to have_text("There are no partner schools for Westbrook Provider")
  end

  def when_i_click_on_add_school
    click_on "Add school"
  end

  def then_i_see_the_add_school_page
    expect(page).to have_title("Add a school - School details - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Schools")
    expect(page).to have_span_caption("School details")
    expect(page).to have_element(:span, class: "govuk-caption-l", text: "School details")
    expect(page).to have_hint("Enter a school name, unique reference number (URN) or postcode")
    expect(page).to have_button("Continue")
    expect(page).to have_link("Cancel")
  end

  def when_i_click_on_back
    click_on "Back"
  end

  def when_i_click_on_continue
    click_on "Continue"
  end
  alias_method :and_i_click_on_continue, :when_i_click_on_continue

  def then_i_see_an_error_that_i_must_enter_a_name_urn_or_postcode
    expect(page).to have_validation_error("Enter a school name, unique reference number (URN) or postcode")
  end

  def when_i_type_in_shelbyville_school
    fill_in "Add a school", with: "Shelbyville Elementary"
  end

  def then_i_see_a_dropdown_item_for_the_shelbyville_school
    expect(page).to have_css(".autocomplete__option", text: "Shelbyville Elementary", wait: 10)
  end

  def when_i_select_shelbyville_school_from_the_dropdown
    page.find(".autocomplete__option", text: "Shelbyville Elementary").click
  end

  def then_i_see_the_check_details_page_for_shelbyville_school
    expect(page).to have_title("Confirm school details - School details - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Schools")
    expect(page).to have_h1("Confirm school details")
    expect(page).to have_text("Once added, they will be able to assign you to their placements.")
    expect(page).to have_text("We will send them an email to let them know you have added them.")
    expect(page).to have_summary_list_row("Name", "Shelbyville Elementary")
    expect(page).to have_summary_list_row("UK provider reference number (UKPRN)", "54321")
    expect(page).to have_summary_list_row("Unique reference number (URN)", "12345")
    expect(page).to have_summary_list_row("Email address", "shelbyville_elementary@sample.com")
    expect(page).to have_summary_list_row("Telephone number", "02083334444")
    expect(page).to have_summary_list_row("Website", "http://www.shelbyville_elementary.com")
    expect(page).to have_summary_list_row("Address", "44 Langton Way")
    expect(page).to have_button("Confirm and add school")
    expect(page).to have_link("Cancel")
  end

  def then_i_see_the_search_input_pre_filled_with_shelbyville_school
    within(".autocomplete__wrapper") do
      find_field "Add a school", with: "Shelbyville Elementary"
    end
  end

  def when_i_click_on_change_name
    within(".govuk-summary-list") do
      click_on "Change"
    end
  end

  def when_i_click_on_confirm_and_add_school
    click_on "Confirm and add school"
  end

  def then_i_return_to_the_partner_school_index_page_with_a_new_partner_school_and_a_success_banner
    expect(page).to have_title("Schools you work with - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Schools")
    expect(page).to have_h1("Schools you work with")
    expect(page).to have_text("View all placements your schools have published.")
    expect(page).to have_text("Only schools you work with are able to assign you their placements.")
    expect(page).to have_link("Add school")
    expect(page).to have_table_row({ "Name": "Shelbyville Elementary",
                                     "Unique reference number (URN)": "12345" })
    expect(page).to have_success_banner("School added", "Shelbyville Elementary can now assign you to their placements.")
  end

  def then_i_see_an_error_that_shelbyville_elementary_has_already_been_added
    expect(page).to have_validation_error("Shelbyville Elementary has already been added. Try another school")
  end
  # let!(:school) { create(:placements_school) }
  # let!(:provider) { create(:placements_provider) }
  # let(:partnership) { create(:placements_partnership, school:, provider:) }

  # before { partnership }

  # scenario "User views a provider partner school" do
  #   given_i_am_signed_in_as_a_placements_user(organisations: [provider])
  #   when_i_view_the_partner_school_show_page
  #   then_i_see_the_details_of(school)
  # end

  # private

  # def when_i_view_the_partner_school_show_page
  #   visit placements_provider_partner_school_path(provider, school)

  #   expect_partner_schools_to_be_selected_in_primary_navigation
  # end

  # def then_i_see_the_details_of(school)
  #   within(".govuk-heading-l") do
  #     expect(page).to have_content school.name
  #   end

  #   expect(page).to have_content "Additional details"
  #   expect(page).to have_content "Special educational needs and disabilities (SEND)"
  #   expect(page).to have_content "Ofsted"

  #   within("#organisation-details") do
  #     expect(page).to have_content "Name"
  #     expect(page).to have_content "UK provider reference number (UKPRN)"
  #     expect(page).to have_content "Unique reference number (URN)"
  #     expect(page).to have_content "Email address"
  #     expect(page).to have_content "Telephone number"
  #     expect(page).to have_content "Website"
  #     expect(page).to have_content "Address"
  #   end

  #   within("#additional-details") do
  #     expect(page).to have_content "Establishment group"
  #     expect(page).to have_content "Phase"
  #     expect(page).to have_content "Gender"
  #     expect(page).to have_content "Age range"
  #     expect(page).to have_content "Religious character"
  #     expect(page).to have_content "Admissions policy"
  #     expect(page).to have_content "Urban or rural"
  #     expect(page).to have_content "School capacity"
  #     expect(page).to have_content "Total pupils"
  #     expect(page).to have_content "Total girls"
  #     expect(page).to have_content "Total boys"
  #     expect(page).to have_content "Percentage free school meals"
  #   end

  #   within("#send-details") do
  #     expect(page).to have_content "Special classes"
  #     expect(page).to have_content "SEND provision"
  #   end

  #   within("#ofsted-details") do
  #     expect(page).to have_content "Rating"
  #     expect(page).to have_content "Last inspection date"
  #   end
  # end

  # def expect_partner_schools_to_be_selected_in_primary_navigation
  #   nav = page.find(".app-primary-navigation__nav")

  #   within(nav) do
  #     expect(page).to have_link "Find", current: "false"
  #     expect(page).to have_link "My placements", current: "false"
  #     expect(page).to have_link "Schools", current: "page"
  #     expect(page).to have_link "Users", current: "false"
  #     expect(page).to have_link "Organisation details", current: "false"
  #   end
  # end
end
