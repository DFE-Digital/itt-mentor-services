require "rails_helper"

RSpec.describe "Provider user views an empty schools list",
               service: :placements, type: :system do
  include ActiveJob::TestHelper

  scenario do
    given_a_school_exists
    and_a_provider_exists
    and_i_am_signed_in

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

  def and_i_am_signed_in
    sign_in_as(@user_anne)
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
    expect(page).to have_element(:p, text: "View all placements your schools have published.")
    expect(page).to have_element(:p, text: "Only schools you work with are able to assign you their placements.")
    expect(page).to have_link("Add school")
    expect(page).to have_element(:p, text: "There are no partner schools for Westbrook Provider")
  end
end
