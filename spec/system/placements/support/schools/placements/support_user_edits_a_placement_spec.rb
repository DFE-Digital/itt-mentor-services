require "rails_helper"

RSpec.describe "Placements / Support / Schools / Placements / Edit a placement",
               service: :placements, type: :system do
  before { given_i_sign_in_as_colin }

  it_behaves_like "an edit placement wizard"

  private

  def given_i_sign_in_as_colin
    and_there_is_an_existing_user_for("Colin")
    and_i_visit_the_sign_in_path
    and_i_click_sign_in
  end

  def and_there_is_an_existing_user_for(user_name)
    user = create(:placements_support_user, user_name.downcase.to_sym)
    user_exists_in_dfe_sign_in(user:)
    create(:user_membership, user:, organisation: school)
  end

  def when_i_visit_the_placement_show_page
    visit placements_school_placement_path(school, placement)
  end

  def then_i_am_redirected_to_add_a_partner_provider
    expect(page).to have_current_path(
      placements_school_partner_providers_path(school), ignore_query: true
    )
  end

  def then_i_am_redirected_to_add_a_mentor
    expect(page).to have_current_path(
      placements_school_mentors_path(school), ignore_query: true
    )
  end
end
