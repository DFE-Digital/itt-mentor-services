require "rails_helper"

RSpec.describe "Support user adds a school", :js, service: :claims, type: :system do
  scenario do
    given_that_schools_exist
    and_claim_windows_exist
    and_i_am_signed_in
    and_i_am_on_the_organisations_index_page

    when_i_click_add_organisation
    then_i_see_the_school_selection_page

    # Invalid: empty input
    when_i_click_continue
    then_i_see_a_validation_error_for_selecting_a_school

    # Invalid: school already added
    when_i_type_st_champions
    and_i_select_st_champions
    and_i_click_continue
    then_i_see_a_validation_error_for_school_already_added

    # Invalid: unknown school
    when_i_type_hogwarts
    then_i_see_no_results_found

    # Valid input
    when_i_type_sherborne
    and_i_select_sherborne_school
    and_i_click_continue
    then_i_see_the_check_your_answers_page
    and_i_see_details_for_sherborne_school

    # Test that the back link navigation works as expected
    when_i_click_on_the_back_link
    then_i_see_the_school_selection_page

    when_i_click_continue
    then_i_see_the_check_your_answers_page
    and_i_see_details_for_sherborne_school

    # Test that the change link functionality works as expected
    when_i_click_change_organisation_name
    then_i_see_the_school_selection_page

    when_i_type_guildford
    and_i_select_royal_grammar_school_guildford
    and_i_click_continue
    then_i_see_the_check_your_answers_page
    and_i_see_details_for_royal_grammar_school_guildford

    # Add the organisation
    when_i_click_save_organisation
    then_i_see_a_success_banner
    and_i_see_the_updated_organisation_index_page
  end

  def given_that_schools_exist
    # Pre-populate an existing school within the service
    create(:school, :claims, name: "St Champions")

    # And a couple of schools which are _not_ in the service yet
    create(
      :school,
      urn: "113918",
      claims_service: false,
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
      claims_service: false,
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

  def and_claim_windows_exist
    @current_claim_window = create(:claim_window, :current).decorate
    @upcoming_claim_window = create(:claim_window, :upcoming).decorate
  end

  def and_i_am_signed_in
    sign_in_claims_support_user
  end

  def and_i_am_on_the_organisations_index_page
    expect(page).to have_current_path(claims_support_schools_path)
    expect(page).to have_title("Organisations (1) - Claim funding for mentor training - GOV.UK")
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

  def when_i_click_save_organisation
    click_on "Save organisation"
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
    expect(page).to have_title("Enter a school name, URN or postcode - Claim funding for mentor training - GOV.UK")
    expect(page).to have_span_caption("Add organisation")
    expect(page).to have_field("Enter a school name, URN or postcode", type: :text)
    expect(page).to have_link("Cancel", href: claims_support_schools_path)
  end

  def then_i_see_a_validation_error_for_selecting_a_school
    expect(page).to have_validation_error("Enter a school name, unique reference number (URN) or postcode")
  end

  def when_i_type_st_champions
    fill_in "Enter a school name", with: "st champions"
  end

  def and_i_select_st_champions
    page.find(".autocomplete__option", text: "St Champions", wait: 10).click
  end

  def then_i_see_a_validation_error_for_school_already_added
    expect(page).to have_validation_error("St Champions has already been added. Try another school")
  end

  def when_i_type_hogwarts
    fill_in "Enter a school name", with: "Hogwarts"
  end

  def then_i_see_no_results_found
    page.find(".autocomplete__option", text: "No results found", wait: 10)
  end

  def when_i_type_sherborne
    fill_in "Enter a school name", with: "sherborne"
  end

  def and_i_select_sherborne_school
    page.find(".autocomplete__option", text: "Sherborne School", wait: 10).click
  end

  def when_i_type_guildford
    fill_in "Enter a school name", with: "guildford"
  end

  def and_i_select_royal_grammar_school_guildford
    page.find(".autocomplete__option", text: "Royal Grammar School Guildford", wait: 10).click
  end

  def then_i_see_the_check_your_answers_page
    expect(page).to have_title("Check your answers - Claim funding for mentor training - GOV.UK")
    expect(page).to have_span_caption("Add organisation")
    expect(page).to have_h1("Check your answers")
    expect(page).to have_link("Cancel", href: claims_support_schools_path)
  end

  def and_i_see_details_for_sherborne_school
    expect(page).to have_summary_list_row("Organisation name", "Sherborne School")
    expect(page).to have_summary_list_row("Claim window", "17 June 2025 to 21 June 2025")
    expect(page).to have_summary_list_row("UK provider reference number (UKPRN)", "10005802")
    expect(page).to have_summary_list_row("Unique reference number (URN)", "113918")

    expect(page).to have_h2("Contact details")
    expect(page).to have_summary_list_row("Telephone number", "01935812249")
    expect(page).to have_summary_list_row("Website", "http://www.sherborne.org")
    expect(page).to have_summary_list_row("Address", "Abbey Road\nSherborne\nDT9 3AP")

    expect(page).to have_button("Save organisation")
    expect(page).to have_link("Cancel")
  end

  def and_i_see_details_for_royal_grammar_school_guildford
    expect(page).to have_summary_list_row("Organisation name", "Royal Grammar School Guildford")
    expect(page).to have_summary_list_row("Claim window", "17 June 2025 to 21 June 2025")
    expect(page).to have_summary_list_row("UK provider reference number (UKPRN)", "10017351")
    expect(page).to have_summary_list_row("Unique reference number (URN)", "125424")

    expect(page).to have_h2("Contact details")
    expect(page).to have_summary_list_row("Telephone number", "01483880600")
    expect(page).to have_summary_list_row("Website", "http://www.rgsg.co.uk")
    expect(page).to have_summary_list_row("Address", "High Street\nGuildford\nGU1 3BB")

    expect(page).to have_button("Save organisation")
    expect(page).to have_link("Cancel")
  end

  def when_i_click_change_organisation_name
    click_on "Change"
  end

  def then_i_see_a_success_banner
    expect(page).to have_success_banner("Organisation added")
  end

  def and_i_see_the_updated_organisation_index_page
    expect(page).to have_current_path(claims_support_schools_path)
    expect(page).to have_title("Organisations (2) - Claim funding for mentor training - GOV.UK")
    expect(page).to have_h1("Organisations (2)")
    within(".organisation-search-results") do
      expect(page).to have_link("St Champions")
      expect(page).not_to have_link("Sherborne School")
      expect(page).to have_link("Royal Grammar School Guildford")
    end
  end
end
