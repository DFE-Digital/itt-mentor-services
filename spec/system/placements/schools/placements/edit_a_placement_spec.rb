require "rails_helper"

RSpec.describe "Placements / Schools / Placements / Edit a placement",
               service: :placements, type: :system do
  before { given_i_am_signed_in_as_a_placements_user(organisations: [school]) }

  it_behaves_like "an edit placement wizard"

  private

  def then_i_am_redirected_to_add_a_partner_provider
    expect(page).to have_current_path(
      placements_school_partner_providers_path(school), ignore_query: true
    )
  end

  def when_i_visit_the_placement_show_page
    visit placements_school_placement_path(school, placement)
  end

  def then_i_am_redirected_to_add_a_mentor
    expect(page).to have_current_path(
      placements_school_mentors_path(school), ignore_query: true
    )
  end
end
