require "rails_helper"

RSpec.describe "Primary school user edits a placement", :js, service: :placements, type: :system do
  scenario do
    given_that_placements_exist
    and_i_am_signed_in

    when_i_am_on_the_placements_index_page
    then_i_see_my_placement

    when_i_click_on_my_placement
    then_i_see_the_placement_details_page

    when_i_click_on_the_back_link
    then_i_see_the_placements_index_page

    when_i_click_on_my_placement
    and_i_click_on_change_year_group
    then_i_see_the_select_a_year_group_page
    and_i_see_the_primary_year_groups

    when_i_click_on_the_cancel_link
    then_i_see_the_placement_details_page

    when_i_click_on_change_year_group
    and_i_select_year_2
    and_i_click_on_continue
    then_i_see_the_placement_details_page_with_my_updated_year_group
    and_i_see_a_year_group_updated_success_message

    when_i_click_on_the_back_link
    then_i_see_the_placements_index_page_with_updated_year_group

    when_i_click_on_my_placement_with_updated_year_group
    and_i_click_on_change_expected_date
    then_i_see_the_when_could_the_placement_take_place_page
    and_i_see_the_term_dates

    when_i_click_on_the_cancel_link
    then_i_see_the_placement_details_page_with_my_updated_year_group

    when_i_click_on_change_expected_date
    and_i_select_summer_term
    and_i_click_on_continue
    then_i_see_the_placement_details_page_with_my_updated_term
    and_i_see_a_term_updated_success_message

    when_i_click_on_select_a_mentor
    then_i_see_the_select_a_mentor_page
    and_i_see_my_mentors

    when_i_click_on_my_mentor_is_not_listed
    then_i_see_the_mentor_not_listed_details_text

    when_i_click_on_the_cancel_link
    then_i_see_the_placement_details_page_with_my_updated_term

    when_i_click_on_select_a_mentor
    and_i_select_john_smith
    and_i_click_on_continue
    then_i_see_the_placement_details_page_with_john_smith
    and_i_see_a_mentor_updated_success_message

    when_i_click_on_change_mentor
    then_i_see_the_select_a_mentor_page
    and_i_see_my_mentors

    when_i_select_jane_doe
    and_i_deselect_john_smith
    and_i_click_on_continue
    then_i_see_the_placement_details_page_with_jane_doe
    and_i_see_a_mentor_updated_success_message

    when_i_click_on_assign_a_provider
    then_i_see_the_select_a_provider_page

    when_i_click_on_the_cancel_link
    then_i_see_the_placement_details_page_with_jane_doe

    when_i_click_on_assign_a_provider
    and_i_enter_aes_sedai_trust
    then_i_see_a_dropdown_item_for_aes_sedai_trust

    when_i_click_on_the_aes_sedai_trust_dropdown_item
    and_i_click_on_continue
    then_i_see_the_placement_details_page_with_aes_sedai_trust
    and_i_see_a_provider_updated_success_message

    when_i_click_on_remove
    then_i_see_the_confirmation_page

    when_i_click_on_remove_provider
    then_i_see_the_provider_was_successfully_removed
    and_i_see_the_placement_details_page_with_jane_doe

    when_i_click_on_preview_this_placement
    then_i_see_the_preview_placement_page

    when_i_click_on_the_back_link
    then_i_see_the_placement_details_page_with_jane_doe
  end

  private

  def given_that_placements_exist
    @aes_sedai_provider = build(:placements_provider, name: "Aes Sedai Trust", postcode: "BR11RP")
    @ashaman_provider = build(:placements_provider, name: "Asha'man Trust")

    @springfield_elementary_school = build(
      :placements_school,
      name: "Springfield Elementary",
      address1: "Westgate Street",
      address2: "Hackney",
      postcode: "E8 3RL",
      group: "Local authority maintained schools",
      phase: "Primary",
      gender: "Mixed",
      minimum_age: 3,
      maximum_age: 11,
      religious_character: "Does not apply",
      admissions_policy: "Not applicable",
      urban_or_rural: "(England/Wales) Urban major conurbation",
      percentage_free_school_meals: 15,
      rating: "Outstanding",
      partner_providers: [@aes_sedai_provider, @ashaman_provider],
    )

    @primary_subject = build(:subject, name: "Primary", subject_area: :primary)

    @autumn_term = build(:placements_term, name: "Autumn term")
    @spring_term = create(:placements_term, name: "Spring term")
    @summer_term = create(:placements_term, name: "Summer term")

    @mentor_john_smith = create(:placements_mentor, first_name: "John", last_name: "Smith", schools: [@springfield_elementary_school])
    @mentor_jane_doe = create(:placements_mentor, first_name: "Jane", last_name: "Doe", schools: [@springfield_elementary_school])

    @next_academic_year = Placements::AcademicYear.current.next
    @next_academic_year_name = @next_academic_year.name

    @placement = create(
      :placement,
      school: @springfield_elementary_school,
      subject: @primary_subject,
      year_group: :year_1,
      academic_year: @next_academic_year,
      terms: [@autumn_term],
    )
    _another_placement = create(
      :placement,
      school: @springfield_elementary_school,
      subject: @primary_subject,
      year_group: :year_5,
      academic_year: @next_academic_year,
    )
  end

  def and_i_am_signed_in
    sign_in_placements_user(organisations: [@springfield_elementary_school])
  end

  def when_i_am_on_the_placements_index_page
    expect(page).to have_title("Placements - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Placements")
    expect(page).to have_h1("Placements")
    expect(page).to have_element(:a, text: "Add placement", class: "govuk-button")
  end

  alias_method :then_i_see_the_placements_index_page, :when_i_am_on_the_placements_index_page

  def then_i_see_my_placement
    expect(page).to have_table_row({
      "Placement" => "Primary (Year 1)",
      "Mentor" => "Mentor not assigned",
      "Expected date" => "Autumn term",
      "Provider" => "Provider not assigned",
    })
  end

  def when_i_click_on_my_placement
    click_on "Primary (Year 1)"
  end

  def then_i_see_the_placement_details_page
    expect(page).to have_title("Primary (Year 1) - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Placements")
    expect(page).to have_tag("Available", "green")
    expect(page).to have_summary_list_row("Subject", "Primary")
    expect(page).to have_summary_list_row("Year group", "Year 1")
    expect(page).to have_summary_list_row("Academic year", "Next year (#{@next_academic_year_name})")
    expect(page).to have_summary_list_row("Expected date", "Autumn term")
    expect(page).to have_summary_list_row("Mentor", "Select a mentor")
    expect(page).to have_summary_list_row("Provider", "Assign a provider")
    expect(page).to have_element(:div, text: "You can preview this placement as it appears to providers.", class: "govuk-inset-text")
    expect(page).to have_link("Delete placement", href: "/schools/#{@springfield_elementary_school.id}/placements/#{@placement.id}/remove")
  end

  def when_i_click_on_the_back_link
    click_on "Back"
  end

  def and_i_click_on_change_year_group
    click_on "Change Year group"
  end

  def then_i_see_the_select_a_year_group_page
    expect(page).to have_title("Select a year group - Placement details - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Placements")
    expect(page).to have_element(:span, text: "Placement details", class: "govuk-caption-l")
    expect(page).to have_element(:h1, text: "Select a year group", class: "govuk-fieldset__heading")
    expect(page).to have_link("Cancel", href: "/schools/#{@springfield_elementary_school.id}/placements/#{@placement.id}")
  end

  def and_i_see_the_primary_year_groups
    expect(page).to have_field("Nursery", type: :radio, visible: :all)
    expect(page).to have_element(:div, text: "3 to 4 years", class: "govuk-hint govuk-radios__hint")
    expect(page).to have_field("Reception", type: :radio, visible: :all)
    expect(page).to have_element(:div, text: "4 to 5 years", class: "govuk-hint govuk-radios__hint")
    expect(page).to have_field("Year 1", type: :radio, visible: :all)
    expect(page).to have_element(:div, text: "5 to 6 years", class: "govuk-hint govuk-radios__hint")
    expect(page).to have_field("Year 2", type: :radio, visible: :all)
    expect(page).to have_element(:div, text: "6 to 7 years", class: "govuk-hint govuk-radios__hint")
    expect(page).to have_field("Year 3", type: :radio, visible: :all)
    expect(page).to have_element(:div, text: "7 to 8 years", class: "govuk-hint govuk-radios__hint")
    expect(page).to have_field("Year 4", type: :radio, visible: :all)
    expect(page).to have_element(:div, text: "8 to 9 years", class: "govuk-hint govuk-radios__hint")
    expect(page).to have_field("Year 5", type: :radio, visible: :all)
    expect(page).to have_element(:div, text: "9 to 10 years", class: "govuk-hint govuk-radios__hint")
    expect(page).to have_field("Year 6", type: :radio, visible: :all)
    expect(page).to have_element(:div, text: "10 to 11 years", class: "govuk-hint govuk-radios__hint")
  end

  def when_i_click_on_the_cancel_link
    click_on "Cancel"
  end

  def when_i_click_on_change_year_group
    click_on "Change Year group"
  end

  def and_i_select_year_2
    choose "Year 2"
  end

  def and_i_click_on_continue
    click_on "Continue"
  end

  def then_i_see_the_placement_details_page_with_my_updated_year_group
    expect(page).to have_title("Primary (Year 2) - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Placements")
    expect(page).to have_tag("Available", "green")
    expect(page).to have_summary_list_row("Subject", "Primary")
    expect(page).to have_summary_list_row("Year group", "Year 2")
    expect(page).to have_summary_list_row("Academic year", "Next year (#{@next_academic_year_name})")
    expect(page).to have_summary_list_row("Expected date", "Autumn term")
    expect(page).to have_summary_list_row("Mentor", "Select a mentor")
    expect(page).to have_summary_list_row("Provider", "Assign a provider")
    expect(page).to have_element(:div, text: "You can preview this placement as it appears to providers.", class: "govuk-inset-text")
    expect(page).to have_link("Delete placement", href: "/schools/#{@springfield_elementary_school.id}/placements/#{@placement.id}/remove")
  end

  def and_i_see_a_year_group_updated_success_message
    expect(page).to have_success_banner("Year group updated")
  end

  def then_i_see_the_placements_index_page_with_updated_year_group
    expect(page).to have_title("Placements - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Placements")
    expect(page).to have_h1("Placements")
    expect(page).to have_element(:a, text: "Add placement", class: "govuk-button")
    expect(page).to have_table_row({
      "Placement" => "Primary (Year 2)",
      "Mentor" => "Mentor not assigned",
      "Expected date" => "Autumn term",
      "Provider" => "Provider not assigned",
    })
  end

  def when_i_click_on_my_placement_with_updated_year_group
    click_on "Primary (Year 2)"
  end

  def when_i_click_on_change_expected_date
    click_on "Change Expected date"
  end
  alias_method :and_i_click_on_change_expected_date, :when_i_click_on_change_expected_date

  def then_i_see_the_when_could_the_placement_take_place_page
    expect(page).to have_title("Select when the placement could be - Placement details - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Placements")
    expect(page).to have_element(:span, text: "Placement details", class: "govuk-caption-l")
    expect(page).to have_element(:div, text: "Provide estimate term dates. You can discuss specific start and end dates with providers after the placement is published.", class: "govuk-hint")
    expect(page).to have_link("Cancel", href: "/schools/#{@springfield_elementary_school.id}/placements/#{@placement.id}")
  end

  def and_i_see_the_term_dates
    expect(page).to have_field("Autumn term", type: :checkbox, visible: :all)
    expect(page).to have_field("Spring term", type: :checkbox, visible: :all)
    expect(page).to have_field("Summer term", type: :checkbox, visible: :all)
    expect(page).to have_field("Any time in the academic year", type: :checkbox, visible: :all)
  end

  def and_i_select_summer_term
    check "Summer term"
  end

  def then_i_see_the_placement_details_page_with_my_updated_term
    expect(page).to have_title("Primary (Year 2) - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Placements")
    expect(page).to have_element(:strong, text: "Available", class: "govuk-tag govuk-tag--green")
    expect(page).to have_summary_list_row("Subject", "Primary")
    expect(page).to have_summary_list_row("Year group", "Year 2")
    expect(page).to have_summary_list_row("Academic year", "Next year (#{@next_academic_year_name})")
    expect(page).to have_summary_list_row("Expected date", "Autumn term, Summer term")
    expect(page).to have_summary_list_row("Mentor", "Select a mentor")
    expect(page).to have_summary_list_row("Provider", "Assign a provider")
    expect(page).to have_element(:div, text: "You can preview this placement as it appears to providers.", class: "govuk-inset-text")
    expect(page).to have_link("Delete placement", href: "/schools/#{@springfield_elementary_school.id}/placements/#{@placement.id}/remove")
  end

  def and_i_see_a_term_updated_success_message
    expect(page).to have_success_banner("Expected date updated")
  end

  def when_i_click_on_select_a_mentor
    click_on "Select a mentor"
  end

  def then_i_see_the_select_a_mentor_page
    expect(page).to have_title("Select who will mentor the trainee - Placement details - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Placements")
    expect(page).to have_element(:span, text: "Placement details", class: "govuk-caption-l")
    expect(page).to have_element(:legend, text: "Select who will mentor the trainee", class: "govuk-fieldset__legend")
    expect(page).to have_element(:div, text: "Only your school will be able to see the assigned mentor. Providers will not have access to this information.", class: "govuk-hint")
    expect(page).to have_element(:span, text: "My mentor is not listed", class: "govuk-details__summary-text")
    expect(page).to have_link("Cancel", href: "/schools/#{@springfield_elementary_school.id}/placements/#{@placement.id}")
  end

  def when_i_click_on_my_mentor_is_not_listed
    # click_on does not work for this element
    find("span.govuk-details__summary-text", text: "My mentor is not listed").click
  end

  def then_i_see_the_mentor_not_listed_details_text
    expect(page).to have_element(:div, text: "You must add mentors to your school's profile before they can be assigned to a specific placement.", class: "govuk-details__text")
    expect(page).to have_link("add mentors to your school's profile", href: "/schools/#{@springfield_elementary_school.id}/mentors/new")
  end

  def and_i_see_my_mentors
    expect(page).to have_field("John Smith", type: :checkbox, visible: :all)
    expect(page).to have_field("Jane Doe", type: :checkbox, visible: :all)
    expect(page).to have_field("Not yet known", type: :checkbox, visible: :all)
  end

  def and_i_select_john_smith
    check "John Smith"
  end

  def then_i_see_the_placement_details_page_with_john_smith
    expect(page).to have_title("Primary (Year 2) - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Placements")
    expect(page).to have_element(:strong, text: "Available", class: "govuk-tag govuk-tag--green")
    expect(page).to have_summary_list_row("Subject", "Primary")
    expect(page).to have_summary_list_row("Year group", "Year 2")
    expect(page).to have_summary_list_row("Academic year", "Next year (#{@next_academic_year_name})")
    expect(page).to have_summary_list_row("Expected date", "Autumn term, Summer term")
    expect(page).to have_summary_list_row("Mentor", "John Smith")
    expect(page).to have_summary_list_row("Provider", "Assign a provider")
    expect(page).to have_element(:div, text: "You can preview this placement as it appears to providers.", class: "govuk-inset-text")
  end

  def and_i_see_a_mentor_updated_success_message
    expect(page).to have_success_banner("Mentor updated")
  end

  def when_i_click_on_change_mentor
    click_on "Change Mentor"
  end

  def when_i_select_jane_doe
    check "Jane Doe"
  end

  def and_i_deselect_john_smith
    uncheck "John Smith"
  end

  def then_i_see_the_placement_details_page_with_jane_doe
    expect(page).to have_tag("Available", "green")
    expect(page).to have_summary_list_row("Subject", "Primary")
    expect(page).to have_summary_list_row("Year group", "Year 2")
    expect(page).to have_summary_list_row("Academic year", "Next year (#{@next_academic_year_name})")
    expect(page).to have_summary_list_row("Expected date", "Autumn term, Summer term")
    expect(page).to have_summary_list_row("Mentor", "Jane Doe")
    expect(page).to have_summary_list_row("Provider", "Assign a provider")
    expect(page).to have_element(:div, text: "You can preview this placement as it appears to providers.", class: "govuk-inset-text")
  end
  alias_method :and_i_see_the_placement_details_page_with_jane_doe,
               :then_i_see_the_placement_details_page_with_jane_doe

  def when_i_click_on_assign_a_provider
    click_on "Assign a provider"
  end

  def then_i_see_the_select_a_provider_page
    expect(page).to have_title("Select a provider - Placement details - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Placements")
    expect(page).to have_element(:span, text: "Placement details", class: "govuk-caption-l")
    expect(page).to have_element(:label, text: "Select a provider", class: "govuk-label--l")
    expect(page).to have_hint("Ensure you have agreed with the provider that their trainee will undertake this placement at your school")
    expect(page).to have_button("Continue")
    expect(page).to have_link("Cancel", href: "/schools/#{@springfield_elementary_school.id}/placements/#{@placement.id}")
  end

  def and_i_enter_aes_sedai_trust
    fill_in "Select a provider", with: "Aes Sedai Trust"
  end

  def then_i_see_a_dropdown_item_for_aes_sedai_trust
    expect(page).to have_css(".autocomplete__option", text: "Aes Sedai Trust (BR11RP)", wait: 10)
  end

  def when_i_click_on_the_aes_sedai_trust_dropdown_item
    page.find(".autocomplete__option", text: "Aes Sedai Trust").click
  end

  def and_i_enter_ashaman_trust
    fill_in "Select a provider", with: "Asha'man Trust"
  end

  def then_i_see_a_dropdown_item_for_ashaman_trust
    expect(page).to have_css(".autocomplete__option", text: "Asha'man Trust", wait: 10)
  end

  def when_i_click_on_the_ashaman_trust_dropdown_item
    page.find(".autocomplete__option", text: "Asha'man Trust").click
  end

  def then_i_see_the_placement_details_page_with_aes_sedai_trust
    expect(page).to have_title("Primary (Year 2) - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Placements")
    expect(page).to have_tag("Assigned to provider", "blue")
    expect(page).to have_summary_list_row("Subject", "Primary")
    expect(page).to have_summary_list_row("Year group", "Year 2")
    expect(page).to have_summary_list_row("Academic year", "Next year (#{@next_academic_year_name})")
    expect(page).to have_summary_list_row("Expected date", "Autumn term, Summer term")
    expect(page).to have_summary_list_row("Mentor", "Jane Doe")
    expect(page).to have_summary_list_row("Provider", "Aes Sedai Trust")
    expect(page).to have_element(:div, text: "You can preview this placement as it appears to providers.", class: "govuk-inset-text")
  end

  def and_i_see_a_provider_updated_success_message
    expect(page).to have_success_banner("Provider updated")
  end

  def when_i_click_on_remove
    click_on("Remove")
  end

  def when_i_click_on_remove_provider
    click_on("Remove provider")
  end

  def then_i_see_the_confirmation_page
    expect(page).to have_title(
      "Are you sure you want to remove Aes Sedai Trust from this placement? - Primary (Year 2) - Manage school placements - GOV.UK",
    )
    expect(page).to have_element(
      :span,
      text: "Primary (Year 2)",
      class: "govuk-caption-l",
    )
    expect(page).to have_h1(
      "Are you sure you want to remove Aes Sedai Trust from this placement?",
    )
    expect(page).to have_element(
      :p,
      text: "We will send an email to let them know they should no longer arrange for a trainee to undertake this placement.",
      class: "govuk-body",
    )
    expect(page).to have_element(
      :p,
      text: "It is your responsibility to contact the provider separately and tell them this placement is no longer available to them.",
      class: "govuk-body",
    )
    expect(page).to have_element(
      :p,
      text: "You can assign a new provider once you have removed the current provider.",
      class: "govuk-body",
    )
    expect(page).to have_button("Remove provider", class: "govuk-button--warning")
  end

  def then_i_see_the_provider_was_successfully_removed
    expect(page).to have_success_banner("Provider removed")
  end

  def when_i_select_the_ashaman_trust
    choose("Asha'man Trust")
  end

  def then_i_see_the_placement_details_page_with_the_ashaman_trust
    expect(page).to have_title("Primary (Year 2) - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Placements")
    expect(page).to have_tag("Unavailable", "orange")
    expect(page).to have_summary_list_row("Subject", "Primary")
    expect(page).to have_summary_list_row("Year group", "Year 2")
    expect(page).to have_summary_list_row("Academic year", "Next year (#{@next_academic_year_name})")
    expect(page).to have_summary_list_row("Expected date", "Autumn term, Summer term")
    expect(page).to have_summary_list_row("Mentor", "Jane Doe")
    expect(page).to have_summary_list_row("Provider", "Asha'man Trust")
    expect(page).to have_element(:div, text: "You can preview this placement as it appears to providers.", class: "govuk-inset-text")
  end

  def when_i_click_on_preview_this_placement
    click_on("preview this placement")
  end

  def then_i_see_the_preview_placement_page
    expect(page).to have_title("Primary (Year 2) - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Placements")
    expect(page).to have_h1("Placement - Springfield Elementary\nPrimary (Year 2)")
    expect(page).to have_important_banner("This is a preview of how your placement appears to teacher training providers.")
    expect(page).to have_h2("Placement dates")
    expect(page).to have_summary_list_row("Academic year", "Next year (#{@next_academic_year_name})")
    expect(page).to have_summary_list_row("Expected date", "Autumn term, Summer term")
    expect(page).to have_h2("Placement contact")
    expect(page).to have_summary_list_row("First name", "Placement")
    expect(page).to have_summary_list_row("Last name", "Coordinator")
    expect(page).to have_summary_list_row("Email address", "placement_coordinator@example.school")
    expect(page).to have_h2("Location")
    expect(page).to have_summary_list_row("Address", "Westgate Street\nHackney\nE8 3RL")
    expect(page).to have_h2("Additional details")
    expect(page).to have_summary_list_row("Establishment group", "Local authority maintained schools")
    expect(page).to have_summary_list_row("School phase", "Primary")
    expect(page).to have_summary_list_row("Gender", "Mixed")
    expect(page).to have_summary_list_row("Age range", "3 to 11")
    expect(page).to have_summary_list_row("Religious character", "Does not apply")
    expect(page).to have_summary_list_row("Urban or rural", "(England/Wales) Urban major conurbation")
    expect(page).to have_summary_list_row("Admissions policy", "Not applicable")
    expect(page).to have_summary_list_row("Percentage free school meals", "15%")
    expect(page).to have_summary_list_row("Ofsted rating", "Outstanding")
  end
end
