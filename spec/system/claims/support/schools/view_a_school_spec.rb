require "rails_helper"

RSpec.describe "View a school", type: :system do
  let!(:support_user) { create(:claims_support_user, :colin) }
  let!(:school) { create(:school, :claims) }

  scenario "View a school's details as a support user" do
    given_i_sign_in_as(support_user)
    and_i_visit_the_school_page(school)
    i_see_the_school_details(school)
    and_i_see_the_secondary_navigation_links(school)
    i_see_the_schools_details_sections
  end

  private

  def and_i_visit_the_school_page(school)
    click_on school.name
  end

  def i_see_the_school_details(school)
    expect(page).to have_selector("h1", text: school.name)
  end

  def and_i_see_the_secondary_navigation_links(school)
    within(".app-secondary-navigation") do
      expect(page).to have_link("Details", href: "/support/schools/#{school.id}")
      expect(page).to have_link("Users", href: "/support/schools/#{school.id}/users")
      expect(page).to have_link("Claims", href: "/support/schools/#{school.id}/claims")
    end
  end

  def i_see_the_schools_details_sections
    expect(page).to have_selector("h2", text: "Grant funding")
    expect(page).to have_selector("h2", text: "Contact details")
  end
end
