require "rails_helper"

RSpec.describe "Authentication", service: :placements, type: :system do
  let(:school) { create(:placements_school, name: "School") }
  let(:anne) { create(:placements_user, :anne) }

  scenario "As a user who has not signed in" do
    when_i_visit_placements_schools_details_path
    then_i_am_unable_to_access_the_page
  end

  scenario "As a user who has signed in" do
    given_i_am_signed_in_as_a_placements_user(organisations: [school])
    and_i_visit_placements_schools_details_path
    then_i_am_able_to_access_the_page
  end

  private

  def when_i_visit_placements_schools_details_path
    visit placements_school_path(school.id)
  end

  def then_i_am_unable_to_access_the_page
    expect(page).to have_content("Sign in to Manage school placements")
  end

  def then_i_am_able_to_access_the_page
    expect(page).to have_content("NameSchool")
  end

  alias_method :and_i_visit_placements_schools_details_path, :when_i_visit_placements_schools_details_path
end
