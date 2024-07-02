require "rails_helper"

RSpec.describe "Placements / Support / Schools / Placements / Add a placement",
               service: :placements, type: :system do
  let!(:subject_1) { create(:subject, name: "Primary subject", subject_area: :primary) }
  let!(:subject_2) { create(:subject, name: "Secondary subject", subject_area: :secondary) }
  let!(:subject_3) { create(:subject, name: "Secondary subject 2", subject_area: :secondary) }
  let!(:mentor_1) { create(:placements_mentor) }
  let!(:mentor_2) { create(:placements_mentor) }

  before do
    given_i_sign_in_as_colin
  end

  it_behaves_like "an add a placement wizard"

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

  def and_i_visit_the_sign_in_path
    visit sign_in_path
  end

  def and_i_click_sign_in
    click_on "Sign in using DfE Sign In"
  end

  def when_i_visit_the_placements_page
    visit placements_support_school_placements_path(school)
  end

  def then_i_see_content(text)
    expect(page).to have_content(text)
  end

  def and_i_do_not_see_the_button_to(button_text)
    expect(page).not_to have_button(button_text)
  end
end
