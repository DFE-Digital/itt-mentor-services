require "rails_helper"

RSpec.describe "Provider user views a placement for a partner school",
               service: :placements, type: :system do
  require "rails_helper"

  scenario do
    given_a_provider_exists_with_a_partner_school
    and_that_partner_school_has_one_assigned_placement
    and_i_am_signed_in

    when_i_navigate_to_the_provider_schools_page
    then_i_see_the_provider_schools_index_with_partner_school

    when_i_click_on_shelbyville_elementary
    then_i_see_the_shelbyville_elementary_show_page

    when_i_navigate_to_the_placments_page
    then_i_see_the_placments_list_for_shelbyville_school

    when_i_click_on_the_assigned_placement
    then_i_see_the_placement_details_page
  end

  private

  def given_a_provider_exists_with_a_partner_school
    @user_anne = build(:placements_user, first_name: "Anne", last_name: "Wilson", email: "anne_wilson@education.gov.uk")
    @provider = build(:placements_provider, name: "Westbrook Provider", users: [@user_anne])
    @shelbyville_elementary = build(
      :placements_school,
      with_school_contact: false,
      name: "Shelbyville Elementary",
      urn: "54321",
      email_address: "www.shelbyville_elementary@sample.com",
      ukprn: "55555",
      address1: "44 Langton Way",
      website: "www.shelbyville_elementary.com",
      telephone: "02083334444",
      group: "Local authority maintained schools",
      phase: "Secondary",
      gender: "Mixed",
      maximum_age: 16,
      minimum_age: 11,
      religious_character: "Church of England",
      admissions_policy: "Comprehensive",
      urban_or_rural: "Urban",
      percentage_free_school_meals: 23,
      rating: "Outstanding",
      last_inspection_date: Date.new(2023, 1, 15),
    )
    @school_contact = create(:school_contact, first_name: "Barry", last_name: "Garlow", email_address: "barry_garlow@education.gov.uk", school: @shelbyville_elementary)
    @shelbyville_partnership = create(:placements_partnership, provider: @provider, school: @shelbyville_elementary)
  end

  def and_that_partner_school_has_one_assigned_placement
    @english_subject = build(:subject, name: "English")
    @assigned_placement = create(:placement, school: @shelbyville_elementary, subject: @english_subject, provider: @provider)
  end

  def and_i_am_signed_in
    sign_in_as(@user_anne)
  end

  def when_i_navigate_to_the_provider_schools_page
    within(".app-primary-navigation") do
      click_on "Schools"
    end
  end

  def then_i_see_the_provider_schools_index_with_partner_school
    expect(page).to have_title("Schools you work with - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Schools")
    expect(page).to have_h1("Schools you work with")
    expect(page).to have_element(:p, text: "View all placements your schools have published.")
    expect(page).to have_element(:p, text: "Only schools you work with are able to assign you their placements.")
    expect(page).to have_link("Add school")
    expect(page).to have_table_row({ "Name": "Shelbyville Elementary",
                                     "Unique reference number (URN)": "54321" })
  end

  def when_i_click_on_shelbyville_elementary
    click_on "Shelbyville Elementary"
  end

  def then_i_see_the_shelbyville_elementary_show_page
    expect(page).to have_title("Partner schools - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Schools")
    expect(page).to have_link("Back")
    expect(page).to have_h1("Shelbyville Elementary")

    within("#organisation-details") do
      expect(page).to have_summary_list_row("Name", "Shelbyville Elementary")
      expect(page).to have_summary_list_row("UK provider reference number (UKPRN)", "55555")
      expect(page).to have_summary_list_row("Unique reference number (URN)", "54321")
      expect(page).to have_summary_list_row("Email address", "www.shelbyville_elementary@sample.com")
      expect(page).to have_summary_list_row("Telephone number", "02083334444")
      expect(page).to have_summary_list_row("Website", "http://www.shelbyville_elementary.com")
      expect(page).to have_summary_list_row("Address", "44 Langton Way")
    end

    expect(page).to have_h2("Additional details")

    expect(page).to have_h2("Special educational needs and disabilities (SEND)")

    expect(page).to have_h2("Ofsted")

    expect(page).to have_link("Delete school")
  end

  def when_i_navigate_to_the_placments_page
    within(".app-secondary-navigation") do
      click_on "Placements"
    end
  end

  def then_i_see_the_placments_list_for_shelbyville_school
    expect(page).to have_title("Placements - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Schools")
    expect(page).to have_link("Back")
    expect(page).to have_h1("Shelbyville Elementary")
    within("table#placements-assigned-to-you") do
      expect(page).to have_content("Placements assigned to you")
      expect(page).to have_table_row({ Subject: "English",
                                       Mentors: "Not yet known" })
    end
  end

  def when_i_click_on_the_assigned_placement
    click_on "English"
  end

  def then_i_see_the_placement_details_page
    expect(page).to have_title("English - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Schools")
    expect(page).to have_link("Back")
    expect(page).to have_h1("English")
    expect(page).to have_element(:strong, class: "govuk-tag govuk-tag--blue", text: "Assigned to you")

    expect(page).to have_h2("Placement dates")
    expect(page).to have_summary_list_row("Academic year", "This year (2024 to 2025)")
    expect(page).to have_summary_list_row("Expected date", "Any time in the academic year")

    expect(page).to have_h2("Placement contact")
    expect(page).to have_summary_list_row("First name", "Barry")
    expect(page).to have_summary_list_row("Last name", "Garlow")
    expect(page).to have_summary_list_row("Email address", "barry_garlow@education.gov.uk")

    expect(page).to have_h2("Location")
    expect(page).to have_summary_list_row("Address", "44 Langton Way")

    expect(page).to have_h2("Additional details")
    expect(page).to have_summary_list_row("Establishment group", "Local authority maintained schools")
    expect(page).to have_summary_list_row("School phase", "Secondary")
    expect(page).to have_summary_list_row("Gender", "Mixed")
    expect(page).to have_summary_list_row("Age range", "11 to 16")
    expect(page).to have_summary_list_row("Religious character", "Church of England")
    expect(page).to have_summary_list_row("Urban or rural", "Urban")
    expect(page).to have_summary_list_row("Admissions policy", "Comprehensive")
    expect(page).to have_summary_list_row("Percentage free school meals", "23%")
    expect(page).to have_summary_list_row("Ofsted rating", "Outstanding")
  end
end
