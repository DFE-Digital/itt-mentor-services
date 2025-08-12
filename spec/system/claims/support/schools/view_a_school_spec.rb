require "rails_helper"

RSpec.describe "View a school", service: :claims, type: :system do
  let!(:support_user) { create(:claims_support_user, :colin) }
  let!(:school) { create(:school, :claims, name: "Hilltop Primary School") }
  let!(:school_not_accepted_grant_conditions) { create(:school, :claims, name: "Sir Thomas Wharton Academy", claims_grant_conditions_accepted_at: nil, claims_grant_conditions_accepted_by_id: nil) }

  scenario "View a school's details as a support user" do
    given_i_sign_in_as(support_user)
    and_i_visit_the_school_page(school)
    and_i_click_on_organsation_details
    i_see_the_school_details(school)
    and_i_see_the_primary_navigation_links(school)
    i_see_the_schools_details_sections
  end

  scenario "View a school's details when they have NOT accepted grant conditions as a support user" do
    given_i_sign_in_as(support_user)
    and_i_visit_the_school_page(school_not_accepted_grant_conditions)
    and_i_click_on_organsation_details
    i_see_the_school_details(school_not_accepted_grant_conditions)
    and_i_see_the_primary_navigation_links(school_not_accepted_grant_conditions)
    i_see_the_schools_details_sections_without_grant_conditions_accepted
  end

  private

  def and_i_visit_the_school_page(school)
    click_on school.name
  end

  def i_see_the_school_details(school)
    expect(page).to have_h1("Organisation details")
    expect(page).to have_summary_list_row(
      "Name",
      school.name,
    )
  end

  def and_i_see_the_primary_navigation_links(school)
    within(primary_navigation) do
      expect(page).to have_link("Organisation details", href: "/schools/#{school.id}")
      expect(page).to have_link("Users", href: "/schools/#{school.id}/users")
      expect(page).to have_link("Claims", href: "/schools/#{school.id}/claims")
    end
  end

  def i_see_the_schools_details_sections
    expect(page).to have_selector("h2", text: "Grant conditions")
    expect(page).to have_selector("h2", text: "Grant funding")
    expect(page).to have_selector("h2", text: "Contact details")
  end

  def i_see_the_schools_details_sections_without_grant_conditions_accepted
    expect(page).to have_content("This school has not agreed to the grant conditions")
  end

  def and_i_click_on_organsation_details
    click_on "Organisation details"
  end
end
