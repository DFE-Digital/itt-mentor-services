require "rails_helper"

RSpec.describe "Provider user adds a school they work with", service: :placements, type: :system do
  scenario do
    given_that_schools_exist
    and_i_am_signed_in
    then_i_am_on_the_placements_page

    when_i_click_on_schools_in_the_primary_navigation
    then_i_see_the_schools_you_work_with_page

    # User clicks the back link
    when_i_click_on_add_school
    then_i_see_the_add_school_page

    when_i_click_on_the_back_link
    then_i_see_the_schools_you_work_with_page

    # User doesn't enter a value for the 'Add a school' field
    when_i_click_on_add_school
    and_i_click_on_continue
    then_i_see_an_enter_school_name_validation_error

    # User enters an unknown school for the 'Add a school' field
    when_i_search_for_an_unknown_school
    and_i_click_on_continue
    then_i_see_the_no_results_page

    # User enters a known school for the 'Add a school' field
    when_i_click_on_try_narrowing_down_your_search
    and_i_search_for_springfield_elementary
    and_i_click_on_continue
    then_i_see_the_results_found_page
    and_i_see_springfield_elementary

    # User doesn't select a value for the 'school' field
    when_i_click_on_continue
    then_i_see_a_select_a_school_validation_error

    # User selects a school
    when_i_choose_springfield_elementary
    and_i_click_on_continue
    then_i_see_the_confirm_school_details_page_with_springfield_elementary

    # User clicks the back link
    when_i_click_on_the_back_link
    then_i_see_the_results_found_page
    and_i_see_springfield_elementary_is_selected

    # User changes their school
    when_i_click_on_continue
    and_i_click_on_change_name
    then_i_see_the_add_school_page

    when_i_search_for_hogwarts
    and_i_click_on_continue
    then_i_see_the_results_found_page
    and_i_see_hogwarts

    when_i_choose_hogwarts
    and_i_click_on_continue
    then_i_see_the_confirm_school_details_page_with_hogwarts

    # User adds the school they work with
    when_i_click_on_confirm_and_add_school
    then_i_see_the_schools_you_work_with_page
    and_i_see_a_success_message
    and_i_see_hogwarts_has_been_added
  end

  private

  def given_that_schools_exist
    @aes_sedai_trust = create(:placements_provider, name: "Aes Sedai Trust")

    @springfield_elementary_school = create(
      :placements_school,
      name: "Springfield Elementary",
      address1: "19 Plympton Street",
      address2: "Springfield",
      postcode: "E8 3RL",
      phase: "Primary",
      telephone: "01234 567890",
      email_address: "itt_contact@springfieldlelementary.ac.uk",
      website: "https://springfieldelementary.ac.uk",
      ukprn: "10032194",
      urn: "102136",
    )

    @hogwarts_school = create(
      :placements_school,
      name: "Hogwarts",
      address1: "Alnwick Castle",
      address2: "Alnwick",
      postcode: "NE66 1YU",
      phase: "Secondary",
      telephone: "01234 567891",
      email_address: "itt_contact@hogwarts.ac.uk",
      website: "https://hogwarts.ac.uk",
      ukprn: "10052837",
      urn: "102139",
    )
  end

  def and_i_am_signed_in
    sign_in_placements_user(organisations: [@aes_sedai_trust])
  end

  def then_i_am_on_the_placements_page
    expect(page).to have_title("Find placements - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Placements")
    expect(page).to have_h1("Find placements")
  end

  def when_i_click_on_schools_in_the_primary_navigation
    within ".app-primary-navigation__nav" do
      click_on "Schools"
    end
  end

  def then_i_see_the_schools_you_work_with_page
    expect(page).to have_title("Schools you work with - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Schools")
    expect(page).to have_h1("Schools you work with")
    expect(page).to have_element(:p, text: "View all placements your schools have published.")
    expect(page).to have_element(:p, text: "Only schools you work with are able to assign you their placements.")
    expect(page).to have_element(:a, text: "Add school", class: "govuk-button")
  end

  def when_i_click_on_add_school
    click_on "Add school"
  end

  def then_i_see_the_add_school_page
    save_and_open_page
    expect(page).to have_title("Add a school - School details - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Schools")
    expect(page).to have_caption("School details")
    expect(page).to have_element(:label, text: "Add a school", class: "govuk-label govuk-label--l")
    expect(page).to have_link("Cancel", href: "/providers/#{@aes_sedai_trust.id}/partner_schools")
  end

  def when_i_click_on_the_back_link
    click_on "Back"
  end

  def then_i_see_an_enter_school_name_validation_error
    expect(page).to have_validation_error("Enter a school name")
  end

  def when_i_search_for_an_unknown_school
    fill_in "Add a school", with: "Mystery High"
  end

  def and_i_click_on_continue
    click_on "Continue"
  end

  alias_method :when_i_click_on_continue, :and_i_click_on_continue

  def then_i_see_the_no_results_page
    expect(page).to have_title("0 results found for ‘Mystery High’ - School details - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Schools")
    expect(page).to have_caption("Add organisation")
    expect(page).to have_h1("No results found for 'Mystery High'")
    expect(page).to have_element(:a, text: "Try narrowing down your search", class: "govuk-link govuk-link--no-visited-state")
    expect(page).to have_link("Cancel", href: "/providers/#{@aes_sedai_trust.id}/partner_schools")
  end

  def when_i_click_on_try_narrowing_down_your_search
    click_on "Try narrowing down your search"
  end

  def and_i_search_for_springfield_elementary
    fill_in "Add a school", with: "Springfield Elementary"
  end

  def then_i_see_the_results_found_page
    expect(page).to have_title("1 results found for ‘Springfield Elementary’ - School details - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Schools")
    expect(page).to have_caption("School details")
    expect(page).to have_legend("1 results found for 'Springfield Elementary'")
    expect(page).to have_element(:a, text: "Cancel", class: "govuk-link")
  end

  def and_i_see_springfield_elementary
    expect(page).to have_field("Springfield Elementary")
  end

  def then_i_see_a_select_a_school_validation_error
    expect(page).to have_validation_error("Select a school")
  end

  def when_i_choose_springfield_elementary
    choose "Springfield Elementary"
  end

  def then_i_see_the_confirm_school_details_page_with_springfield_elementary
    expect(page).to have_title("Confirm school details - School details - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Schools")
    expect(page).to have_h1("Confirm school details")
    expect(page).to have_element(:p, text: "Once added, they will be able to assign you to their placements.")
    expect(page).to have_element(:p, text: "We will send them an email to let them know you have added them.")
    expect(page).to have_summary_list_row("Name", "Springfield Elementary")
    expect(page).to have_summary_list_row("UK provider reference number (UKPRN)", "10032194")
    expect(page).to have_summary_list_row("Unique reference number (URN)", "102136")
    expect(page).to have_summary_list_row("Email address", "itt_contact@springfieldlelementary.ac.uk")
    expect(page).to have_summary_list_row("Telephone number", "01234 567890")
    expect(page).to have_summary_list_row("Website", "https://springfieldelementary.ac.uk (opens in new tab)")
    expect(page).to have_summary_list_row("Address", "19 Plympton Street Springfield E8 3RL")
  end

  def and_i_see_springfield_elementary_is_selected
    expect(page).to have_checked_field("Springfield Elementary")
  end

  def and_i_click_on_change_name
    click_on "Change Name"
  end

  def when_i_search_for_hogwarts
    fill_in "Add a school", with: "Hogwarts"
  end

  def and_i_see_hogwarts
    expect(page).to have_field("Hogwarts")
  end

  def when_i_choose_hogwarts
    choose "Hogwarts"
  end

  def then_i_see_the_confirm_school_details_page_with_hogwarts
    expect(page).to have_title("Confirm school details - School details - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Schools")
    expect(page).to have_h1("Confirm school details")
    expect(page).to have_summary_list_row("Name", "Hogwarts")
    expect(page).to have_summary_list_row("UK provider reference number (UKPRN)", "10052837")
    expect(page).to have_summary_list_row("Unique reference number (URN)", "102139")
    expect(page).to have_summary_list_row("Email address", "itt_contact@hogwarts.ac.uk")
    expect(page).to have_summary_list_row("Telephone number", "01234 567891")
    expect(page).to have_summary_list_row("Website", "https://hogwarts.ac.uk (opens in new tab)")
    expect(page).to have_summary_list_row(
      "Address",
      <<~ADDR.chomp,
        Alnwick Castle
        Alnwick
        NE66 1YU
      ADDR
    )
  end

  def when_i_click_on_confirm_and_add_school
    click_on "Confirm and add school"
  end

  def and_i_see_a_success_message
    expect(page).to have_success_banner("School added")
  end

  def and_i_see_hogwarts_has_been_added
    expect(page).to have_table_row({
      "Name" => "Hogwarts",
      "Unique reference number (URN)" => "102139",
    })
  end
end
