require "rails_helper"

RSpec.describe "Feedback Page", type: :system, service: :placements do
  scenario "User visits the feedback page" do
    given_i_am_on_the_feedback_page
    then_i_can_see_the_feedback_page
  end

  private

  def given_i_am_on_the_feedback_page
    visit placements_feedback_path
  end

  def then_i_can_see_the_feedback_page
    within(".govuk-header") do
      expect(page).to have_content("GOV.UK Manage school placements")
    end

    expect(page).to have_content("Feedback")
  end
end
