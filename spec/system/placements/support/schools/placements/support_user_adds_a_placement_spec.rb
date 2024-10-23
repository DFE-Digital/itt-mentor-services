require "rails_helper"

RSpec.describe "Placements / Support / Schools / Placements / Add a placement",
               service: :placements, type: :system do
  before do
    given_i_am_signed_in_as_a_placements_support_user
  end

  it_behaves_like "an add a placement wizard"

  private

  def when_i_visit_the_placements_page
    visit placements_school_placements_path(school)
  end

  def then_i_see_content(text)
    expect(page).to have_content(text)
  end

  def and_i_do_not_see_the_button_to(button_text)
    expect(page).not_to have_button(button_text)
  end
end
