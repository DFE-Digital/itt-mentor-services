require "rails_helper"

RSpec.describe "Provider user views a school which is not onboarded", service: :placements, type: :system do
  scenario do
    given_that_schools_exist
    and_i_am_signed_in

    when_i_navigate_to_the_find_schools_page
    then_i_see_the_find_schools_page
    and_i_see_all_schools
    and_i_cannot_see_a_link_to_view_the_school_that_is_not_onboarded
  end

  private

  def given_that_schools_exist
    @provider = build(:placements_provider, name: "Aes Sedai Trust")
    @not_onboarded_school = create(:placements_school, with_hosting_interest: false, phase: "Secondary", name: "Shelbyville High School")
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

  def and_i_cannot_see_a_link_to_view_the_school_that_is_not_onboarded
    expect(page).not_to have_link("Shelbyville High School", href: placements_placements_provider_find_path(@provider, @not_onboarded_school))
    expect(page).not_to have_link("Shelbyville High School", href: placement_contact_placements_provider_find_path(@provider, @not_onboarded_school))
  end
end
