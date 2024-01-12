require "rails_helper"

RSpec.describe "View a school", type: :system do
  scenario "View a school's details as a support user" do
    when_i_sign_in_as_a_support_user
    school = and_there_is_a_school
    when_i_visit_the_school_page(school)
    i_see_the_school_details(school)
    and_i_see_the_secondary_navigation_links(school)
    i_see_the_schools_details_sections
  end

  private

  def when_i_sign_in_as_a_support_user
    create(:persona, :colin, service: "claims")
    visit personas_path
    click_on "Sign In as Colin"
  end

  def and_there_is_a_school
    create(:school, :claims, urn: "123456")
  end

  def when_i_visit_the_school_page(school)
    visit "/support/schools/#{school.id}"
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
    expect(page).to have_selector("h2", text: "Additional Details")
    expect(page).to have_selector("h2", text: "Send")
    expect(page).to have_selector("h2", text: "Ofsted")
    expect(page).to have_selector("h2", text: "Contact Details")
  end
end
