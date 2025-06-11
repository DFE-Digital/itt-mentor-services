require "rails_helper"

RSpec.describe "Support user views a populated schools list",
               service: :placements, type: :system do
  scenario do
    given_two_schools_exist_with_a_provider_partnership_and_a_provider_user
    and_one_school_exists_without_a_provider_partnership
    given_i_am_signed_in_as_a_placements_support_user

    when_i_click_on_westbrook_provider
    then_i_see_the_find_page

    when_i_navigate_to_the_provider_schools_page
    then_i_see_the_provider_schools_index_with_the_two_partnered_schools
    and_i_do_not_see_the_unpartnered_school
  end

  private

  def given_two_schools_exist_with_a_provider_partnership_and_a_provider_user
    @user_anne = build(:placements_user, first_name: "Anne", last_name: "Wilson", email: "anne_wilson@education.gov.uk")
    @provider = build(:placements_provider, name: "Westbrook Provider", users: [@user_anne])
    @partnered_school_one = build(
      :placements_school,
      name: "Shelbyville School",
      urn: "12345",
    )
    @partnered_school_two = build(
      :placements_school,
      name: "Springfield School",
      urn: "54321",
    )
    @school_partnership_one = create(:placements_partnership, school: @partnered_school_one, provider: @provider)
    @school_partnership_two = create(:placements_partnership, school: @partnered_school_two, provider: @provider)
  end

  def and_one_school_exists_without_a_provider_partnership
    @unpartnered_school = create(
      :placements_school,
      name: "Lonely School",
      urn: "55555",
    )
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

  def then_i_see_the_provider_schools_index_with_the_two_partnered_schools
    expect(page).to have_title("Schools you work with - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Schools")
    expect(page).to have_h1("Schools you work with")
    expect(page).to have_paragraph("View all placements your schools have published.")
    expect(page).to have_paragraph("Only schools you work with are able to assign you their placements.")
    expect(page).to have_link("Add school", href: new_add_partner_school_placements_provider_partner_schools_path(@provider))
    expect(page).to have_table_row({ "Name": "Shelbyville School",
                                     "Unique reference number (URN)": "12345" })
    expect(page).to have_table_row({ "Name": "Springfield School",
                                     "Unique reference number (URN)": "54321" })
  end

  def and_i_do_not_see_the_unpartnered_school
    expect(page).not_to have_table_row({ "Name": "Lonely School",
                                         "Unique reference number (URN)": "55555" })
  end
end
