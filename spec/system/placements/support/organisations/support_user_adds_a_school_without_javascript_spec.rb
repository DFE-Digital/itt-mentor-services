require "rails_helper"

RSpec.describe "Support user adds a school without JavaScript", service: :placements, type: :system do
  scenario do
    given_that_schools_exist
    and_i_am_signed_in
    and_i_am_on_the_organisations_index_page

    when_i_click_add_organisation
    then_i_see_the_organisation_type_page

    when_i_click_on_the_back_link
    then_i_see_the_organisations_index_page

    when_i_click_add_organisation
    and_i_click_continue
    then_i_see_a_validation_error_for_selecting_an_organisation_type

    when_i_select_school
    and_i_click_continue
    then_i_see_the_school_selection_page

    # Invalid: empty input
    when_i_click_continue
    then_i_see_a_validation_error_for_selecting_a_school

    # Invalid: school already added
    when_i_type_st_champions
    and_i_click_continue
    then_i_see_search_results_for_st_champions

    when_i_select_st_champions
    and_i_click_continue
    then_i_see_a_validation_error_for_school_already_added

    when_i_click_change_your_search
    then_i_see_the_school_selection_page

    # Invalid: unknown school
    when_i_type_hogwarts
    and_i_click_continue
    then_i_see_no_results_found

    when_i_click_try_narrowing_down_your_search
    then_i_see_the_school_selection_page

    # Valid input
    when_i_type_sherborne
    and_i_click_continue
    then_i_see_search_results_for_sherborne

    when_i_select_sherborne_school
    and_i_click_continue
    then_i_see_the_check_your_answers_page
    and_i_see_details_for_sherborne_school

    # Test that the back link navigation works as expected
    when_i_click_on_the_back_link
    then_i_see_search_results_for_sherborne

    when_i_click_on_the_back_link
    then_i_see_the_school_selection_page

    when_i_click_on_the_back_link
    then_i_see_the_organisation_type_page

    when_i_click_continue
    then_i_see_the_school_selection_page

    when_i_click_continue
    then_i_see_search_results_for_sherborne

    when_i_click_continue
    then_i_see_the_check_your_answers_page
    and_i_see_details_for_sherborne_school

    # Test that the change link functionality works as expected
    when_i_click_change_name
    then_i_see_the_school_selection_page

    when_i_type_guildford
    and_i_click_continue
    then_i_see_search_results_for_guildford

    when_i_select_royal_grammar_school_guildford
    and_i_click_continue
    then_i_see_the_check_your_answers_page
    and_i_see_details_for_royal_grammar_school_guildford

    # Add the organisation
    when_i_click_add_organisation
    then_i_see_a_success_banner
    and_i_see_the_updated_organisation_index_page
  end

  def given_that_schools_exist
    # Pre-populate an existing school within the service
    create(:school, :placements, name: "St Champions")

    # And a couple of schools which are _not_ in the service yet
    create(
      :school,
      urn: "113918",
      placements_service: false,
      name: "Sherborne School",
      postcode: "DT9 3AP",
      town: "Sherborne",
      ukprn: "10005802",
      telephone: "01935812249",
      website: "www.sherborne.org",
      address1: "Abbey Road",
      group: "Independent schools",
      type_of_establishment: "Other independent school",
      phase: "Not applicable",
      gender: "Boys",
      minimum_age: 13,
      maximum_age: 18,
      religious_character: "Christian",
      admissions_policy: "Selective",
      urban_or_rural: "(England/Wales) Rural town and fringe",
      school_capacity: 600,
      total_pupils: 584,
      total_girls: 0,
      total_boys: 584,
      special_classes: "No Special Classes",
    )

    create(
      :school,
      urn: "125424",
      placements_service: false,
      name: "Royal Grammar School Guildford",
      postcode: "GU1 3BB",
      ukprn: "10017351",
      telephone: "01483880600",
      website: "www.rgsg.co.uk",
      address1: "High Street",
      address2: "Guildford",
      group: "Independent schools",
      type_of_establishment: "Other independent school",
      phase: "Not applicable",
      gender: "Boys",
      minimum_age: 3,
      maximum_age: 18,
      religious_character: "Christian",
      admissions_policy: "Selective",
      urban_or_rural: "(England/Wales) Urban city and town",
      school_capacity: 1373,
      total_pupils: 1306,
      total_girls: 0,
      total_boys: 1306,
      special_classes: "No Special Classes",
    )
  end

  def and_i_am_signed_in
    sign_in_placements_support_user
  end

  def and_i_am_on_the_organisations_index_page
    expect(page).to have_current_path(placements_support_organisations_path)
    expect(page).to have_title("Organisations (1) - Manage school placements - GOV.UK")
    expect(page).to have_h1("Organisations (1)")
    within(".organisation-search-results") do
      expect(page).to have_link("St Champions")
      expect(page).not_to have_link("Sherborne School")
      expect(page).not_to have_link("Royal Grammar School Guildford")
    end
  end
  alias_method :then_i_see_the_organisations_index_page, :and_i_am_on_the_organisations_index_page

  def when_i_click_add_organisation
    click_on "Add organisation"
  end

  def then_i_see_the_organisation_type_page
    expect(page).to have_title("Organisation type - Manage school placements - GOV.UK")
    expect(page).to have_element(:span, text: "Add organisation", class: "govuk-caption-l")
    expect(page).to have_element(:legend, text: "Organisation type", class: "govuk-fieldset__legend")
    expect(page).to have_field("Teacher training provider", type: :radio, visible: :all)
    expect(page).to have_field("School", type: :radio, visible: :all)
    expect(page).to have_link("Cancel", href: placements_support_organisations_path)
  end

  def when_i_click_on_the_back_link
    click_on "Back"
  end

  def and_i_click_continue
    click_on "Continue"
  end
  alias_method :when_i_click_continue, :and_i_click_continue

  def then_i_see_a_validation_error_for_selecting_an_organisation_type
    expect(page).to have_validation_error("Select an organisation type")
  end

  def when_i_select_school
    choose "School"
  end

  def then_i_see_the_school_selection_page
    expect(page).to have_title("Enter a school name, unique reference number (URN) or postcode - Manage school placements - GOV.UK")
    expect(page).to have_element(:span, text: "Add organisation", class: "govuk-caption-l")
    expect(page).to have_field("Enter a school name, unique reference number (URN) or postcode", type: :text)
    expect(page).to have_link("Cancel", href: placements_support_organisations_path)
  end

  def then_i_see_a_validation_error_for_selecting_a_school
    expect(page).to have_validation_error("Enter a school name, unique reference number (URN) or postcode")
  end

  def when_i_type_st_champions
    fill_in "Enter a school name", with: "st champions"
  end

  def then_i_see_search_results_for_st_champions
    expect(page).to have_title("1 results found for ‘st champions’ - Add organisation - Manage school placements - GOV.UK")
    expect(page).to have_element(:span, text: "Add organisation", class: "govuk-caption-l")
    expect(page).to have_element(:legend, text: "1 results found for 'st champions'", class: "govuk-fieldset__legend")
    expect(page).to have_link("Cancel", href: placements_support_organisations_path)
  end

  def when_i_select_st_champions
    choose "St Champions"
  end

  def then_i_see_a_validation_error_for_school_already_added
    expect(page).to have_validation_error("St Champions has already been added. Try another school")
  end

  def when_i_type_hogwarts
    fill_in "Enter a school name", with: "Hogwarts"
  end

  def then_i_see_no_results_found
    expect(page).to have_title("0 results found for ‘Hogwarts’ - Add organisation - Manage school placements - GOV.UK")
    expect(page).to have_element(:span, text: "Add organisation", class: "govuk-caption-l")
    expect(page).to have_h1("No results found for 'Hogwarts'")
    expect(page).to have_link("Cancel", href: placements_support_organisations_path)
  end

  def when_i_click_change_your_search
    click_on "Change your search"
  end

  def when_i_click_try_narrowing_down_your_search
    click_on "Try narrowing down your search"
  end

  def when_i_type_sherborne
    fill_in "Enter a school name", with: "sherborne"
  end

  def then_i_see_search_results_for_sherborne
    expect(page).to have_title("1 results found for ‘sherborne’ - Add organisation - Manage school placements - GOV.UK")
    expect(page).to have_element(:span, text: "Add organisation", class: "govuk-caption-l")
    expect(page).to have_element(:legend, text: "1 results found for 'sherborne'", class: "govuk-fieldset__legend")
    expect(page).to have_link("Cancel", href: placements_support_organisations_path)
  end

  def when_i_select_sherborne_school
    choose "Sherborne School"
  end

  def when_i_type_guildford
    fill_in "Enter a school name", with: "guildford"
  end

  def then_i_see_search_results_for_guildford
    expect(page).to have_title("1 results found for ‘guildford’ - Add organisation - Manage school placements - GOV.UK")
    expect(page).to have_element(:span, text: "Add organisation", class: "govuk-caption-l")
    expect(page).to have_element(:legend, text: "1 results found for 'guildford'", class: "govuk-fieldset__legend")
    expect(page).to have_link("Cancel", href: placements_support_organisations_path)
  end

  def when_i_select_royal_grammar_school_guildford
    choose "Royal Grammar School Guildford"
  end

  def then_i_see_the_check_your_answers_page
    expect(page).to have_title("Check your answers - Manage school placements - GOV.UK")
    expect(page).to have_element(:span, text: "Add organisation", class: "govuk-caption-l")
    expect(page).to have_h1("Check your answers")
    expect(page).to have_link("Cancel", href: placements_support_organisations_path)
  end

  def and_i_see_details_for_sherborne_school
    expect(page).to have_summary_list_row("Name", "Sherborne School")
    expect(page).to have_summary_list_row("UK provider reference number (UKPRN)", "10005802")
    expect(page).to have_summary_list_row("Unique reference number (URN)", "113918")
    expect(page).to have_summary_list_row("Email address", "Not entered")
    expect(page).to have_summary_list_row("Telephone number", "01935812249")
    expect(page).to have_summary_list_row("Website", "http://www.sherborne.org (opens in new tab)")
    expect(page).to have_summary_list_row("Address", "Abbey Road Sherborne DT9 3AP")

    expect(page).to have_h2("Additional details")
    expect(page).to have_summary_list_row("Establishment group", "Independent schools")
    expect(page).to have_summary_list_row("Phase", "Not applicable")
    expect(page).to have_summary_list_row("Gender", "Boys")
    expect(page).to have_summary_list_row("Age range", "13 to 18")
    expect(page).to have_summary_list_row("Religious character", "Christian")
    expect(page).to have_summary_list_row("Admissions policy", "Selective")
    expect(page).to have_summary_list_row("Urban or rural", "(England/Wales) Rural town and fringe")
    expect(page).to have_summary_list_row("School capacity", "600")
    expect(page).to have_summary_list_row("Total pupils", "584")
    expect(page).to have_summary_list_row("Total boys", "584")
    expect(page).to have_summary_list_row("Total girls", "0")
    expect(page).to have_summary_list_row("Percentage free school meals", "Not entered")

    expect(page).to have_h2("Special educational needs and disabilities (SEND)")
    expect(page).to have_summary_list_row("Special classes", "No Special Classes")
    expect(page).to have_summary_list_row("SEND provision", "Not entered")

    expect(page).to have_h2("Ofsted")
    expect(page).to have_summary_list_row("Rating", "Unknown")
    expect(page).to have_summary_list_row("Last inspection date", "Unknown")
  end

  def and_i_see_details_for_royal_grammar_school_guildford
    expect(page).to have_summary_list_row("Name", "Royal Grammar School Guildford")
    expect(page).to have_summary_list_row("UK provider reference number (UKPRN)", "10017351")
    expect(page).to have_summary_list_row("Unique reference number (URN)", "125424")
    expect(page).to have_summary_list_row("Email address", "Not entered")
    expect(page).to have_summary_list_row("Telephone number", "01483880600")
    expect(page).to have_summary_list_row("Website", "http://www.rgsg.co.uk (opens in new tab)")
    expect(page).to have_summary_list_row("Address", "High Street Guildford GU1 3BB")

    expect(page).to have_h2("Additional details")
    expect(page).to have_summary_list_row("Establishment group", "Independent schools")
    expect(page).to have_summary_list_row("Phase", "Not applicable")
    expect(page).to have_summary_list_row("Gender", "Boys")
    expect(page).to have_summary_list_row("Age range", "3 to 18")
    expect(page).to have_summary_list_row("Religious character", "Christian")
    expect(page).to have_summary_list_row("Admissions policy", "Selective")
    expect(page).to have_summary_list_row("Urban or rural", "(England/Wales) Urban city and town")
    expect(page).to have_summary_list_row("School capacity", "1,373")
    expect(page).to have_summary_list_row("Total pupils", "1,306")
    expect(page).to have_summary_list_row("Total boys", "1,306")
    expect(page).to have_summary_list_row("Total girls", "0")
    expect(page).to have_summary_list_row("Percentage free school meals", "Not entered")

    expect(page).to have_h2("Special educational needs and disabilities (SEND)")
    expect(page).to have_summary_list_row("Special classes", "No Special Classes")
    expect(page).to have_summary_list_row("SEND provision", "Not entered")

    expect(page).to have_h2("Ofsted")
    expect(page).to have_summary_list_row("Rating", "Unknown")
    expect(page).to have_summary_list_row("Last inspection date", "Unknown")
  end

  def when_i_click_change_name
    click_on "Change Name"
  end

  def then_i_see_a_success_banner
    expect(page).to have_success_banner("Organisation added")
  end

  def and_i_see_the_updated_organisation_index_page
    expect(page).to have_current_path(placements_support_organisations_path)
    expect(page).to have_title("Organisations (2) - Manage school placements - GOV.UK")
    expect(page).to have_h1("Organisations (2)")
    within(".organisation-search-results") do
      expect(page).to have_link("St Champions")
      expect(page).not_to have_link("Sherborne School")
      expect(page).to have_link("Royal Grammar School Guildford")
    end
  end
end
