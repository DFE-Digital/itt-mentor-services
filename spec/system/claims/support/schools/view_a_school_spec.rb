require "rails_helper"

RSpec.describe "View a school", type: :system do
  let!(:support_user) { create(:persona, :colin, service: :claims) }
  let!(:school) { create(:school, :claims) }

  scenario "View a school's details as a support user" do
    when_i_sign_in_as_a_support_user(support_user)
    and_i_visit_the_school_page(school)
    i_see_the_school_details(school)
    and_i_see_the_secondary_navigation_links(school)
    i_see_the_schools_details_sections
  end

  private

  def when_i_sign_in_as_a_support_user(support_user)
    visit claims_root_path
    click_on "Sign In as #{support_user.first_name}"
  end

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
    expect(page).to have_selector("h2", text: "Additional details")
    expect(page).to have_selector("h2", text: "Special educational needs and disabilities (SEND)")
    expect(page).to have_selector("h2", text: "Ofsted")
    expect(page).to have_selector("h2", text: "Contact details")
  end
end
