require "rails_helper"

RSpec.describe "Support user views an empty schools list",
               service: :placements, type: :system do
  include ActiveJob::TestHelper

  scenario do
    given_a_school_exists
    and_a_provider_exists
    given_i_am_signed_in_as_a_placements_support_user

    when_i_click_on_westbrook_provider
    then_i_see_the_find_page

    when_i_navigate_to_the_provider_schools_page
    then_i_see_the_provider_schools_index_with_no_schools
  end

  private

  def given_a_school_exists
    @user_anne = build(:placements_user, first_name: "Anne", last_name: "Wilson", email: "anne_wilson@education.gov.uk")
    @shelbyville_school = create(:placements_school)
  end

  def and_a_provider_exists
    @provider = create(:placements_provider, users: [@user_anne], name: "Westbrook Provider")
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

  def then_i_see_the_provider_schools_index_with_no_schools
    expect(page).to have_title("Schools you work with - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Schools")
    expect(page).to have_h1("Schools you work with")
    expect(page).to have_paragraph("View all placements your schools have published.")
    expect(page).to have_paragraph("Only schools you work with are able to assign you their placements.")
    expect(page).to have_link("Add school", href: new_add_partner_school_placements_provider_partner_schools_path(@provider))
    expect(page).to have_paragraph("There are no partner schools for Westbrook Provider")
  end
end
