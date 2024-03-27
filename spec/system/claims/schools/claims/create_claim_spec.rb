require "rails_helper"

RSpec.describe "Create claim", type: :system, service: :claims do
  let(:mentor1) { build(:claims_mentor, first_name: "Anne") }
  let(:mentor2) { build(:claims_mentor, first_name: "Joe") }
  let!(:school) { create(:claims_school, mentors: [mentor1, mentor2], region: regions(:inner_london)) }
  let!(:anne) do
    create(
      :claims_user,
      :anne,
      user_memberships: [create(:user_membership, organisation: school)],
    )
  end
  let!(:provider) { create(:claims_provider, :best_practice_network) }

  before do
    user_exists_in_dfe_sign_in(user: anne)
    given_i_sign_in
  end

  scenario "Anne creates a claim" do
    when_i_click("Add claim")
    when_i_choose_a_provider
    when_i_click("Continue")
    when_i_select_all_mentors
    when_i_click("Continue")
    then_i_expect_to_be_able_to_add_training_hours_to_mentor(mentor1)
    when_i_add_training_hours("20 hours")
    when_i_click("Continue")
    then_i_expect_to_be_able_to_add_training_hours_to_mentor(mentor2)
    when_i_choose_other_amount_and_input_hours(12)
    when_i_click("Continue")
    then_i_check_my_answers
    when_i_click("Submit claim")
    then_i_get_a_claim_reference(Claims::Claim.submitted.first)
  end

  scenario "Anne does not fill the form correctly" do
    when_i_click("Add claim")
    when_i_click("Continue")
    then_i_see_the_error("Select a provider")
    when_i_choose_a_provider
    when_i_click("Continue")
    when_i_click("Continue")
    then_i_see_the_error("Select a mentor")
    when_i_select_all_mentors
    when_i_click("Continue")
    when_i_click("Continue")
    then_i_see_the_error("Select the number of hours")
    when_i_choose_other_amount
    when_i_click("Continue")
    then_i_see_the_error("Enter the number of hours")
    when_i_choose_other_amount_and_input_hours(-1)
    when_i_click("Continue")
    then_i_see_the_error("Enter the number of hours between 1 and 20")
    when_i_choose_other_amount_and_input_hours(21)
    when_i_click("Continue")
    then_i_see_the_error("Enter the number of hours between 1 and 20")
    when_i_choose_other_amount_and_input_hours(0.5)
    when_i_click("Continue")
    then_i_see_the_error("Enter the number of hours between 1 and 20")
  end

  scenario "Anne creates a claim and tries to edit it" do
    when_i_click("Add claim")
    when_i_choose_a_provider
    when_i_click("Continue")
    when_i_select_a_mentor(mentor1)
    when_i_click("Continue")
    when_i_add_training_hours("20 hours")
    when_i_click("Continue")
    when_i_click("Submit claim")
    then_i_get_a_claim_reference(Claims::Claim.submitted.last)
    given_i_visit_claim_check_page_after_submitting(Claims::Claim.submitted.last)
    then_i_am_redirected_to_root_path_with_alert
  end

  private

  def given_i_sign_in
    visit sign_in_path
    click_on "Sign in using DfE Sign In"
  end

  def when_i_click(button)
    click_on(button)
  end

  def when_i_choose_a_provider
    page.choose(provider.name)
  end

  def when_i_select_all_mentors
    page.check(mentor1.full_name)
    page.check(mentor2.full_name)
  end

  def when_i_select_a_mentor(mentor)
    page.check(mentor.full_name)
  end

  def then_i_expect_to_be_able_to_add_training_hours_to_mentor(mentor)
    expect(page).to have_content("Hours of training for #{mentor.full_name}")
  end

  def when_i_add_training_hours(radio_button)
    page.choose(radio_button)
  end

  def when_i_choose_other_amount
    page.choose("Another amount")
  end

  def when_i_choose_other_amount_and_input_hours(hours)
    page.choose("Another amount")
    fill_in("Enter whole numbers up to a maximum of 20 hours", with: hours)
  end

  def then_i_check_my_answers
    expect(page).to have_content("Check your answers")
    expect(page).to have_content("Hours of training")
    expect(page).to have_content("Grant funding")

    within("dl.govuk-summary-list:nth(1)") do
      within(".govuk-summary-list__row:nth(2)") do
        expect(page).to have_content("Accredited provider")
        expect(page).to have_content(provider.name)
      end

      within(".govuk-summary-list__row:nth(3)") do
        expect(page).to have_content("Mentors")
        expect(page).to have_content(mentor1.full_name)
        expect(page).to have_content(mentor2.full_name)
      end
    end

    within("dl.govuk-summary-list:nth(2)") do
      within(".govuk-summary-list__row:nth(1)") do
        expect(page).to have_content(mentor1.full_name)
        expect(page).to have_content("20 hours")
      end

      within(".govuk-summary-list__row:nth(2)") do
        expect(page).to have_content(mentor2.full_name)
        expect(page).to have_content("12 hours")
      end
    end

    within("dl.govuk-summary-list:nth(3)") do
      within(".govuk-summary-list__row:nth(1)") do
        expect(page).to have_content("Claim amount")
        expect(page).to have_content("£1715.20")
      end
    end
  end

  def then_i_get_a_claim_reference(claim)
    within(".govuk-panel") do
      expect(page).to have_content("Claim submitted\nYour reference number\n#{claim.reference}")
    end
  end

  def then_i_see_the_error(message)
    within(".govuk-error-summary") do
      expect(page).to have_content message
    end

    within(".govuk-form-group--error") do
      expect(page).to have_content message
    end
  end

  def given_i_visit_claim_check_page_after_submitting(claim)
    Capybara.current_session.driver.header(
      "Referer",
      check_claims_school_claim_url(school, claim),
    )

    visit check_claims_school_claim_path(school, claim)
  end

  def then_i_am_redirected_to_root_path_with_alert
    expect(page.current_url).to eq(claims_school_claims_url(school))
    expect(page).to have_content "You cannot perform this action"
  end
end
