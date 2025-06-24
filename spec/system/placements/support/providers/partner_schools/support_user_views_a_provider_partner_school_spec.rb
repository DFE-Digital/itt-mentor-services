require "rails_helper"

RSpec.describe "Support user views a provider partner school",
               service: :placements, type: :system do
  scenario do
    given_a_provider_exists_with_a_partner_school
    given_i_am_signed_in_as_a_placements_support_user

    when_i_click_on_westbrook_provider
    then_i_see_the_find_page

    when_i_navigate_to_the_provider_schools_page
    then_i_see_the_provider_schools_index_with_two_schools

    when_i_click_on_shelbyville_elementary
    then_i_see_the_shelbyville_elementary_show_page
  end

  private

  def given_a_provider_exists_with_a_partner_school
    @user_anne = build(:placements_user, first_name: "Anne", last_name: "Wilson", email: "anne_wilson@education.gov.uk")
    @provider = build(:placements_provider, name: "Westbrook Provider", users: [@user_anne])
    @shelbyville_elementary = build(
      :placements_school,
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
      school_capacity: 1200,
      total_pupils: 1100,
      total_boys: 550,
      total_girls: 550,
      percentage_free_school_meals: 23,
      special_classes: "No special classes",
      send_provision: "Specialist resource base",
      rating: "Outstanding",
      last_inspection_date: Date.new(2023, 1, 15),
    )
    @shelbyville_partnership = create(:placements_partnership, provider: @provider, school: @shelbyville_elementary)
  end

  def when_i_click_on_westbrook_provider
    click_on "Westbrook Provider"
  end

  def then_i_see_the_find_page
    expect(page).to have_title("Find schools hosting placements - Manage school placements - GOV.UK")
    expect(page).to have_element(:span, text: "Westbrook Provider", class: "govuk-heading-s")
    expect(primary_navigation).to have_current_item("Find")
    expect(page).to have_h1("Find schools hosting placements")
  end

  def when_i_navigate_to_the_provider_schools_page
    within(primary_navigation) do
      click_on "Schools"
    end
  end

  def then_i_see_the_provider_schools_index_with_two_schools
    expect(page).to have_title("Schools you work with - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Schools")
    expect(page).to have_h1("Schools you work with")
    expect(page).to have_paragraph("View all placements your schools have published.")
    expect(page).to have_link("Add school", href: new_add_partner_school_placements_provider_partner_schools_path(@provider))
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
    within("#additional-details") do
      expect(page).to have_summary_list_row("Establishment group", "Local authority maintained schools")
      expect(page).to have_summary_list_row("Phase", "Secondary")
      expect(page).to have_summary_list_row("Gender", "Mixed")
      expect(page).to have_summary_list_row("Age range", "11 to 16")
      expect(page).to have_summary_list_row("Religious character", "Church of England")
      expect(page).to have_summary_list_row("Admissions policy", "Comprehensive")
      expect(page).to have_summary_list_row("Urban or rural", "Urban")
      expect(page).to have_summary_list_row("School capacity", "1,200")
      expect(page).to have_summary_list_row("Total pupils", "1,100")
      expect(page).to have_summary_list_row("Total boys", "550")
      expect(page).to have_summary_list_row("Total girls", "550")
      expect(page).to have_summary_list_row("Percentage free school meals", "23%")
    end

    expect(page).to have_h2("Special educational needs and disabilities (SEND)")
    within("#send-details") do
      expect(page).to have_summary_list_row("Special classes", "No special classes")
      expect(page).to have_summary_list_row("SEND provision", "Specialist resource base")
    end

    expect(page).to have_h2("Ofsted")
    within("#ofsted-details") do
      expect(page).to have_summary_list_row("Rating", "Outstanding")
      expect(page).to have_summary_list_row("Last inspection date", "15 January 2023")
    end

    expect(page).to have_link("Delete school", href: remove_placements_provider_partner_school_path(@provider, @shelbyville_elementary))
  end
end
