require "rails_helper"

RSpec.describe "Provider user views a placements already organised school", service: :placements, type: :system do
  scenario do
    given_that_schools_exist
    and_i_am_signed_in

    when_i_navigate_to_the_find_schools_page
    then_i_see_the_find_schools_page
    and_i_see_all_schools

    when_i_click_on_the_already_organised_school_name
    then_i_can_see_the_placements_school_detail_page
    and_i_do_not_see_available_placements

    when_i_navigate_to_the_placement_contact_page
    then_i_see_the_placement_contact_page

    when_i_navigate_to_the_school_details_page
    then_i_see_the_school_details_page
  end

  private

  def given_that_schools_exist
    @academic_year = Placements::AcademicYear.current.next
    @provider = build(:placements_provider, name: "Aes Sedai Trust")
    placements = build_list(:placement, 1, provider: @provider, terms: [build(:placements_term, :spring)], subject: build(:subject, name: "Primary (Year 1)"), academic_year: @academic_year)
    hosting_interests = build_list(:hosting_interest, 1, appetite: "actively_looking", academic_year: @academic_year)
    @already_hosting_school = create(
      :placements_school,
      phase: "Secondary",
      name: "Shelbyville High School",
      minimum_age: 11,
      maximum_age: 16,
      urn: "123456",
      ukprn: "12345678",
      telephone: "01234567890",
      website: "www.shelbyville.sch.uk",
      address1: "123 Main St",
      town: "Shelbyville",
      postcode: "12345",
      type_of_establishment: "Voluntary controlled school",
      gender: "Mixed",
      religious_character: "Church of England",
      admissions_policy: "Not applicable",
      urban_or_rural: "Urban city and town",
      school_capacity: 147,
      total_boys: 53,
      total_girls: 62,
      percentage_free_school_meals: 17,
      special_classes: "No Special Classes",
      send_provision: "Resourced provision",
      hosting_interests:,
      placements:,
    )
  end

  def and_i_am_signed_in
    sign_in_placements_user(organisations: [@provider])
  end

  def when_i_navigate_to_the_find_schools_page
    within ".app-primary-navigation__nav" do
      click_on "Find"
    end
  end

  def then_i_see_the_find_schools_page
    expect(page).to have_title("Find schools hosting placements - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Find")
    expect(page).to have_h1("Find schools hosting placements")
    expect(page).to have_h2("Filter")
  end

  def and_i_see_all_schools
    expect(page).to have_content("Shelbyville High School")
  end

  def when_i_click_on_the_already_organised_school_name
    click_on "Shelbyville High School"
  end

  def then_i_can_see_the_placements_school_detail_page
    expect(page).to have_title("Shelbyville High School - Find - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Find")
    expect(page).to have_h1("Shelbyville High School")
    expect(page).to have_tag("No placements available", "blue")
    expect(secondary_navigation).to have_current_item("Placements")
    expect(page).to have_element(:p, text: "This school has specified which placements they can offer in the #{@academic_year.name} academic year.", class: "govuk-body")
    expect(page).to have_h2("1 filled placement")
    expect(page).to have_table_row({
      "Subject" => "Primary (Year 1)",
      "Expected date" => "Spring term",
    })
  end

  def and_i_do_not_see_available_placements
    expect(page).not_to have_h2("Available placements")
  end

  def when_i_navigate_to_the_placement_contact_page
    click_on "Contact"
  end

  def then_i_see_the_placement_contact_page
    expect(page).to have_title("Shelbyville High School - Find - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Find")
    expect(page).to have_h1("Shelbyville High School")
    expect(page).to have_tag("No placements available", "blue")
    expect(page).to have_paragraph("Email this school if you have suitable trainees.")
    expect(secondary_navigation).to have_current_item("Contact")
    expect(page).to have_h2("Placement contact")
    expect(page).to have_summary_list_row("Name", "Placement Coordinator")
    expect(page).to have_summary_list_row("Email", "placement_coordinator@example.school")
  end

  def when_i_navigate_to_the_school_details_page
    click_on "School details"
  end

  def then_i_see_the_school_details_page
    expect(page).to have_title("Shelbyville High School - Find - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Find")
    expect(page).to have_h1("Shelbyville High School")
    expect(page).to have_tag("No placements available", "blue")
    expect(secondary_navigation).to have_current_item("School details")

    expect(page).to have_h2("School details")
    expect(page).to have_summary_list_row("Phase", "Secondary")
    expect(page).to have_summary_list_row("Age range", "11 to 16")
    expect(page).to have_summary_list_row("UK provider reference number (UKPRN)", "12345678")
    expect(page).to have_summary_list_row("Unique reference number (URN)", "123456")

    expect(page).to have_h2("General contact details")
    expect(page).to have_summary_list_row("Telephone number", "01234567890")
    expect(page).to have_summary_list_row("Website", "www.shelbyville.sch.uk (opens in new tab)")
    expect(page).to have_link("www.shelbyville.sch.uk (opens in new tab)", href: "http://www.shelbyville.sch.uk", target: "_blank")
    expect(page).to have_summary_list_row("Address", "123 Main St Shelbyville 12345")

    expect(page).to have_h2("Additional details")
    expect(page).to have_summary_list_row("School type", "Voluntary controlled school")
    expect(page).to have_summary_list_row("Gender", "Mixed")
    expect(page).to have_summary_list_row("Religious character", "Church of England")
    expect(page).to have_summary_list_row("Admissions policy", "Not applicable")
    expect(page).to have_summary_list_row("Urban or rural", "Urban city and town")
    expect(page).to have_summary_list_row("School capacity", "147")
    expect(page).to have_summary_list_row("Total boys", "53")
    expect(page).to have_summary_list_row("Total girls", "62")
    expect(page).to have_summary_list_row("Percentage free school meals", "17%")

    expect(page).to have_h2("Special educational needs and disabilities (SEND)")
    expect(page).to have_summary_list_row("Special classes", "No Special Classes")
    expect(page).to have_summary_list_row("SEN provision", "Resourced provision")

    expect(page).to have_h2("OFSTED")
    expect(page).to have_summary_list_row("Rating", "Why the rating is not displayed")
    expect(page).to have_summary_list_row("Last inspection date", "Unknown")
  end
end
