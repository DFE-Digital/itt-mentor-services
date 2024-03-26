require "rails_helper"

RSpec.describe "Feedback Page", type: :system, service: :claims do
  scenario "User visits the feedback page and succesfully submits" do
    given_i_am_on_the_feedback_page
    when_i_fill_in_the_required_form_fields
    then_i_successfully_submit
  end

  scenario "User visits the feedback page and unsuccesfully submits" do
    given_i_am_on_the_feedback_page
    then_i_see_the_form_errors
  end

  scenario "User visits the feedback page and types more than 200 words" do
    given_i_am_on_the_feedback_page
    when_i_type_more_than_200_words
    then_i_see_the_word_count_error
  end

  private

  def given_i_am_on_the_feedback_page
    visit new_claims_feedback_path
  end

  def when_i_fill_in_the_required_form_fields
    page.choose("Very satisfied")
    fill_in "improve_comment", with: "I LOVE IT"
  end

  def when_i_type_more_than_200_words
    comment = Faker::Lorem.words(number: 205).join(" ")

    page.choose("Very satisfied")
    fill_in "improve_comment", with: comment
  end

  def then_i_successfully_submit
    click_on "Send feedback"
    expect(page).to have_content("Thank you for submitting feedback")
    expect(page).to have_content("If you gave us your name and email, we will respond within 5 working days.")
    expect(page).to have_content("Return to the home page")
  end

  def then_i_see_the_word_count_error
    click_on "Send feedback"
    expect(page).to have_content("Details must be 200 words or fewer")
  end

  def then_i_see_the_form_errors
    click_on "Send feedback"
    expect(page).not_to have_content("Thank you for submitting feedback")
    expect(page).to have_content("Select how you feel about this service")
  end
end
