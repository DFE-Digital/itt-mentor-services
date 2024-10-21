require "rails_helper"

RSpec.describe "Placements / Schools / Placements / Add a placement",
               service: :placements, type: :system do
  before do
    given_i_am_signed_in_as_a_placements_user(organisations: [school])
  end

  context "when the school has no school contact assigned" do
    let(:school) { build(:placements_school, with_school_contact: false) }

    it "does not allow the user to add a placement" do
      when_i_visit_the_placements_page
      then_i_see_content(
        "Before you add a placement, you must add a placement contact so that the teacher training providers can contact you.",
      )
      and_i_do_not_see_the_button_to("Add placement")
    end
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
