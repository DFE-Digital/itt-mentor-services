require "rails_helper"

RSpec.describe "Support user adds a provider without JavaScript", service: :placements, type: :system do
  scenario do
    given_that_providers_exist
    and_i_am_signed_in
    and_i_am_on_the_organisations_index_page

    when_i_click_add_organisation
    then_i_see_the_organisation_type_page

    when_i_click_on_the_back_link
    then_i_see_the_organisations_index_page

    when_i_click_add_organisation
    and_i_click_continue
    then_i_see_a_validation_error_for_selecting_an_organisation_type

    when_i_select_teacher_training_provider
    and_i_click_continue
    then_i_see_the_provider_selection_page

    # Invalid: empty input
    when_i_click_continue
    then_i_see_a_validation_error_for_selecting_a_provider

    # Invalid: provider already added
    when_i_type_banana
    and_i_click_continue
    then_i_see_search_results_for_banana

    when_i_select_university_of_banana
    and_i_click_continue
    then_i_see_a_validation_error_for_provider_already_added

    when_i_click_change_your_search
    then_i_see_the_provider_selection_page

    # Invalid: unknown provider
    when_i_type_plumb
    and_i_click_continue
    then_i_see_no_results_found

    when_i_click_try_narrowing_down_your_search
    then_i_see_the_provider_selection_page

    # Valid input
    when_i_type_apple
    and_i_click_continue
    then_i_see_search_results_for_apple

    when_i_select_pineapple_university
    and_i_click_continue
    then_i_see_the_check_your_answers_page
    and_i_see_details_for_pineapple_university

    # Test that the back link navigation works as expected
    when_i_click_on_the_back_link
    then_i_see_search_results_for_apple

    when_i_click_on_the_back_link
    then_i_see_the_provider_selection_page

    when_i_click_on_the_back_link
    then_i_see_the_organisation_type_page

    when_i_click_continue
    then_i_see_the_provider_selection_page

    when_i_click_continue
    then_i_see_search_results_for_apple

    when_i_click_continue
    then_i_see_the_check_your_answers_page
    and_i_see_details_for_pineapple_university

    # Test that the change link functionality works as expected
    when_i_click_change_name
    then_i_see_the_provider_selection_page

    when_i_type_apple
    and_i_click_continue
    then_i_see_search_results_for_apple

    when_i_select_apple_academy
    and_i_click_continue
    then_i_see_the_check_your_answers_page
    and_i_see_details_for_apple_academy

    # Add the organisation
    when_i_click_add_organisation
    then_i_see_a_success_banner
    and_i_see_the_updated_organisation_index_page
  end

  def given_that_providers_exist
    # Pre-populate an existing provider within the service
    create(:provider, name: "University of Banana", placements_service: true)

    # And a couple of providers which are _not_ in the service yet
    create(
      :provider,
      name: "Pineapple University",
      placements_service: false,
      ukprn: "UKPRN01",
      urn: "URN01",
      email_address: "itt@pineapple.university",
      telephone: "(020) 0401 7222",
      website: "https://pineapple.university",
      address1: "Pineapple University",
      address2: "The Fruit Bowl",
      city: "London",
      postcode: "SW4 9QZ",
    )

    create(
      :provider,
      name: "Apple Academy",
      placements_service: false,
      ukprn: "APPLE5",
      urn: "APL5",
      email_address: "placements@apple.academy",
      telephone: "01175 698444",
      website: "https://apple.academy",
      address1: "Apple Academy",
      address2: "The Orchard",
      city: "Bristol",
      postcode: "BS1 5AY",
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
      expect(page).to have_link("University of Banana")
      expect(page).not_to have_link("Apple Academy")
      expect(page).not_to have_link("Pineapple University")
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

  def when_i_select_teacher_training_provider
    choose "Teacher training provider"
  end

  def then_i_see_the_provider_selection_page
    expect(page).to have_title("Enter a provider name, United Kingdom provider number (UKPRN), unique reference number (URN) or postcode. - Manage school placements - GOV.UK")
    expect(page).to have_element(:span, text: "Add organisation", class: "govuk-caption-l")
    expect(page).to have_field("Enter a provider name, United Kingdom provider number (UKPRN), unique reference number (URN) or postcode.", type: :text)
    expect(page).to have_link("Cancel", href: placements_support_organisations_path)
  end

  def then_i_see_a_validation_error_for_selecting_a_provider
    expect(page).to have_validation_error("Enter a provider name, United Kingdom provider number (UKPRN), unique reference number (URN) or postcode")
  end

  def then_i_see_a_validation_error_for_provider_already_added
    expect(page).to have_validation_error("University of Banana has already been added. Try another provider")
  end

  def when_i_type_banana
    fill_in "Enter a provider", with: "banana"
  end

  def then_i_see_search_results_for_banana
    expect(page).to have_title("1 results found for ‘banana’ - Add organisation - Manage school placements - GOV.UK")
    expect(page).to have_element(:span, text: "Add organisation", class: "govuk-caption-l")
    expect(page).to have_element(:legend, text: "1 results found for 'banana'", class: "govuk-fieldset__legend")
    expect(page).to have_link("Cancel", href: placements_support_organisations_path)
  end

  def when_i_select_university_of_banana
    choose "University of Banana"
  end

  def when_i_click_change_your_search
    click_on "Change your search"
  end

  def when_i_type_plumb
    fill_in "Enter a provider", with: "plumb"
  end

  def then_i_see_no_results_found
    expect(page).to have_title("0 results found for ‘plumb’ - Add organisation - Manage school placements - GOV.UK")
    expect(page).to have_element(:span, text: "Add organisation", class: "govuk-caption-l")
    expect(page).to have_h1("No results found for 'plumb'")
    expect(page).to have_link("Cancel", href: placements_support_organisations_path)
  end

  def when_i_click_try_narrowing_down_your_search
    click_on "Try narrowing down your search"
  end

  def when_i_type_apple
    fill_in "Enter a provider", with: "apple"
  end

  def then_i_see_search_results_for_apple
    expect(page).to have_title("2 results found for ‘apple’ - Add organisation - Manage school placements - GOV.UK")
    expect(page).to have_element(:span, text: "Add organisation", class: "govuk-caption-l")
    expect(page).to have_element(:legend, text: "2 results found for 'apple'", class: "govuk-fieldset__legend")
    expect(page).to have_field("Pineapple University", type: :radio)
    expect(page).to have_field("Apple Academy", type: :radio)
    expect(page).to have_link("Cancel", href: placements_support_organisations_path)
  end

  def when_i_select_pineapple_university
    choose "Pineapple University"
  end

  def when_i_select_apple_academy
    choose "Apple Academy"
  end

  def then_i_see_the_check_your_answers_page
    expect(page).to have_title("Check your answers - Manage school placements - GOV.UK")
    expect(page).to have_element(:span, text: "Add organisation", class: "govuk-caption-l")
    expect(page).to have_h1("Check your answers")
    expect(page).to have_link("Cancel", href: placements_support_organisations_path)
  end

  def and_i_see_details_for_pineapple_university
    expect(page).to have_summary_list_row("Name", "Pineapple University")
    expect(page).to have_summary_list_row("UK provider reference number (UKPRN)", "UKPRN01")
    expect(page).to have_summary_list_row("Unique reference number (URN)", "URN01")
    expect(page).to have_summary_list_row("Email address", "itt@pineapple.university")
    expect(page).to have_summary_list_row("Telephone number", "(020) 0401 7222")
    expect(page).to have_summary_list_row("Website", "https://pineapple.university (opens in new tab)")
    expect(page).to have_summary_list_row("Address", "Pineapple University The Fruit Bowl London SW4 9QZ")
  end

  def and_i_see_details_for_apple_academy
    expect(page).to have_summary_list_row("Name", "Apple Academy")
    expect(page).to have_summary_list_row("UK provider reference number (UKPRN)", "APPLE5")
    expect(page).to have_summary_list_row("Unique reference number (URN)", "APL5")
    expect(page).to have_summary_list_row("Email address", "placements@apple.academy")
    expect(page).to have_summary_list_row("Telephone number", "01175 698444")
    expect(page).to have_summary_list_row("Website", "https://apple.academy (opens in new tab)")
    expect(page).to have_summary_list_row("Address", "Apple Academy The Orchard Bristol BS1 5AY")
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
      expect(page).to have_link("University of Banana")
      expect(page).to have_link("Apple Academy")
      expect(page).not_to have_link("Pineapple University")
    end
  end
end
