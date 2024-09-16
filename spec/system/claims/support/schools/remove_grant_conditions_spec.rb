require "rails_helper"

RSpec.describe "Remove a users agreement to the grant conditions for a school", service: :claims, type: :system do
  let!(:support_user) { create(:claims_support_user, :colin) }
  let!(:claims_user) { create(:claims_user, first_name: "George", last_name: "Barlow") }

  let!(:school) { create(:claims_school, claims_grant_conditions_accepted_at: Time.zone.now, claims_grant_conditions_accepted_by_id: claims_user.id) }

  before do
    school.users << claims_user
  end

  scenario "When a support user removes a schools agreement to grant conditions" do
    given_i_sign_in_as(support_user)
    and_i_visit_the_school_page(school)
    i_see_the_school_details(school)
    click_on "Remove user's agreement to the grant conditions"
    i_then_see_the_remove_agreement_check_page
    click_on "Remove agreement"
    then_see_the_agreement_has_been_removed
  end

  private

  def then_see_the_agreement_has_been_removed
    expect(page).to have_content("Agreement to grant conditions removed")
    expect(page).to have_content("This school has not agreed to the grant conditions")
  end

  def i_then_see_the_remove_agreement_check_page
    expect(page).to have_content("Are you sure you want to remove George Barlow's agreement?")
  end

  def and_i_visit_the_school_page(school)
    click_on school.name
  end

  def i_see_the_school_details(school)
    expect(page).to have_selector("h1", text: school.name)
  end

  def i_see_the_schools_details_sections_without_grant_conditions_accepted
    expect(page).to have_content("This school has not agreed to the grant conditions")
  end
end
