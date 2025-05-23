require "rails_helper"

RSpec.describe "Provider views an empty schools list",
               service: :placements, type: :system do
  include ActiveJob::TestHelper

  scenario do
    given_a_school_exists_with_a_provider
    given_i_am_signed_in

    when_i_navigate_to_the_provider_schools_page
    then_i_see_the_provider_schools_index_with_no_schools
  end

  private

  def given_a_school_exists_with_a_provider
    @user_anne = build(:placements_user, first_name: "Anne", last_name: "Wilson", email: "anne_wilson@education.gov.uk")
    @provider = create(:placements_provider, users: [@user_anne], name: "Westbrook Provider")
    @shelbyville_school = create(
      :placements_school,
    )
  end

  def given_i_am_signed_in
    sign_in_as(@user_anne)
  end

  def when_i_navigate_to_the_provider_schools_page
    within(".app-primary-navigation") do
      click_on "Schools"
    end
  end

  def then_i_see_the_provider_schools_index_with_no_schools
    expect(page).to have_title("Schools you work with - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Schools")
    expect(page).to have_h1("Schools you work with")
    expect(page).to have_text("View all placements your schools have published.")
    expect(page).to have_text("Only schools you work with are able to assign you their placements.")
    expect(page).to have_link("Add school")
    expect(page).to have_text("There are no partner schools for Westbrook Provider")
  end
end
