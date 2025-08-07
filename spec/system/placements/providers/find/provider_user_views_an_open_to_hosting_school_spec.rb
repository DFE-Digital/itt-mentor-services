require "rails_helper"

RSpec.describe "Provider user views a school which is open to hosting", service: :placements, type: :system do
  scenario do
    given_that_schools_exist
    and_i_am_signed_in

    when_i_navigate_to_the_find_schools_page
    then_i_see_the_find_schools_page
    and_i_see_all_schools

    when_i_click_on_the_open_to_hosting_school_name
    then_i_see_the_placements_page

    when_i_navigate_to_the_school_details_page
    then_i_see_the_school_details_page
  end

  private

  def given_that_schools_exist
    academic_year = Placements::AcademicYear.current.next
    @provider = build(:placements_provider, name: "Aes Sedai Trust")
    hosting_interests = build_list(:hosting_interest, 1, appetite: "interested", academic_year:)
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
      potential_placement_details: { "phase" => { "phases" => %w[Primary Secondary] },
                                     "note_to_providers" => { "note" => "We are a small school." },
                                     "year_group_selection" => { "year_groups" => ["Year 1, Year 2"] },
                                     "secondary_placement_quantity" => { "biology" => 1, "chemistry" => 2 },
                                     "year_group_placement_quantity" => { "year_1" => 2, "year_2" => 1 } },
      hosting_interests:,
    )
  end

  def and_i_am_signed_in
    sign_in_placements_user(organisations: [@provider])
  end

  def when_i_navigate_to_the_find_schools_page
    within primary_navigation do
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

  def when_i_click_on_the_open_to_hosting_school_name
    click_on "Shelbyville High School"
  end

  def then_i_see_the_placements_page
    expect(page).to have_title("Shelbyville High School - Find - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Find")
    expect(page).to have_h1("Shelbyville High School")
    expect(page).to have_tag("May offer placements", "yellow")
    expect(page).to have_paragraph("Email this school if you have suitable trainees.")
    expect(secondary_navigation).to have_current_item("Placements")
    expect(page).to have_summary_list_row("Phase", "Primary Secondary")
    expect(page).to have_h2("Potential primary school placements")
    expect(page).to have_summary_list_row("Year group", "Number of placements")
    expect(page).to have_summary_list_row("Year 1", "2")
    expect(page).to have_summary_list_row("Year 2", "1")
    expect(page).to have_h2("Potential secondary school placements")
    expect(page).to have_summary_list_row("Subject", "Number of placements")
    expect(page).to have_summary_list_row("Biology", "1")
    expect(page).to have_summary_list_row("Chemistry", "2")
    expect(page).to have_h2("Additional information")
    expect(page).to have_summary_list_row("Message to providers", "We are a small school.")
  end

  def when_i_navigate_to_the_school_details_page
    click_on "School details"
  end

  def then_i_see_the_school_details_page
    expect(page).to have_title("Shelbyville High School - Find - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Find")
    expect(page).to have_h1("Shelbyville High School")
    expect(page).to have_tag("May offer placements", "yellow")
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
