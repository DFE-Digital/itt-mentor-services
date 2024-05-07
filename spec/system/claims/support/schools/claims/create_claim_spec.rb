require "rails_helper"

RSpec.describe "Create claim", type: :system, service: :claims do
  let!(:school) { create(:claims_school) }
  let!(:mentor1) { create(:claims_mentor, first_name: "Anne", schools: [school]) }
  let!(:mentor2) { create(:claims_mentor, first_name: "Joe", schools: [school]) }
  let!(:colin) do
    create(
      :claims_support_user,
      :colin,
      user_memberships: [create(:user_membership, organisation: school)],
    )
  end
  let!(:bpn) { create(:claims_provider, :best_practice_network) }
  let!(:niot) { create(:claims_provider, :niot) }

  before do
    user_exists_in_dfe_sign_in(user: colin)
    given_i_sign_in
  end

  scenario "Colin creates a claim" do
    when_i_click(school.name)
    when_i_click_on_claims
    when_i_click("Add claim")
    when_i_choose_a_provider(bpn)
    when_i_click("Continue")
    when_i_select_all_mentors
    when_i_click("Continue")
    then_i_expect_to_be_able_to_add_training_hours_to_mentor(mentor1)
    when_i_add_training_hours("20 hours")
    when_i_click("Continue")
    then_i_expect_to_be_able_to_add_training_hours_to_mentor(mentor2)
    when_i_choose_other_amount_and_input_hours(12)
    when_i_click("Back")
    then_i_expect_the_training_hours_for(20, mentor1)
    when_i_click("Continue")
    then_i_expect_to_be_able_to_add_training_hours_to_mentor(mentor2)
    when_i_choose_other_amount_and_input_hours(12)
    when_i_click("Continue")
    then_i_check_my_answers
    when_i_click("Save claim")
    then_i_am_redirectd_to_index_page(Claims::Claim.draft.first)
  end

  scenario "Colin attempts to create a claim but backs off before the check page" do
    when_i_click(school.name)
    when_i_click_on_claims
    when_i_click("Add claim")
    when_i_choose_a_provider(bpn)
    when_i_click("Continue")
    when_i_select_all_mentors
    when_i_click("Continue")
    then_i_expect_to_be_able_to_add_training_hours_to_mentor(mentor1)
    when_i_add_training_hours("20 hours")
    when_i_click("Continue")
    then_i_expect_to_be_able_to_add_training_hours_to_mentor(mentor2)
    when_i_click("Back")
    then_i_expect_the_training_hours_for(20, mentor1)
    when_i_click("Back")
    then_i_expect_the_mentors_to_be_checked([mentor1, mentor2])
    when_i_click("Back")
    then_i_expect_the_provider_to_be_checked(bpn)
    when_i_click("Back")
    then_i_expect_to_be_on_the_claims_index_page
  end

  scenario "Colin creates a claim with mentor training hours over the maximum limit per provider" do
    when_i_click(school.name)
    when_i_click_on_claims
    when_i_click("Add claim")
    when_i_choose_a_provider(bpn)
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
    when_another_claim_with_same_mentors_has_been_created([mentor1, mentor2])
    when_i_click("Save claim")
    then_i_get_the_reject_page
  end

  scenario "Colin does not fill the form correctly" do
    when_i_click(school.name)
    when_i_click_on_claims
    when_i_click("Add claim")
    when_i_click("Continue")
    then_i_see_the_error("Select a provider")
    when_i_choose_a_provider(bpn)
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
    then_i_see_the_error("Enter whole numbers only")
  end

  scenario "School attempts to create a claim when their mentors have all been claimed for" do
    given_my_school_has_fully_claimed_for_all_mentors_for_provider(bpn)
    when_i_click(school.name)
    when_i_click_on_claims
    when_i_click("Add claim")
    when_i_choose_a_provider(bpn)
    when_i_click("Continue")
    then_i_should_see_the_message("There are no mentors you can include in a claim because they have already had 20 hours of training claimed for with Best Practice Network.")
  end

  scenario "School attempts to create a claim then changes the provider to an invalid one" do
    given_my_school_has_fully_claimed_for_all_mentors_for_provider(bpn)
    when_i_click(school.name)
    when_i_click_on_claims
    when_i_click("Add claim")
    when_i_choose_a_provider(niot)
    when_i_click("Continue")
    when_i_select_a_mentor(mentor1)
    when_i_click("Continue")
    then_i_expect_to_be_able_to_add_training_hours_to_mentor(mentor1)
    when_i_add_training_hours("20 hours")
    when_i_click("Continue")
    when_i_click("Change Accredited provider")
    when_i_choose_a_provider(bpn)
    when_i_click("Continue")
    when_i_click("Change Mentors")
    then_i_should_see_the_message("There are no mentors you can include in a claim because they have already had 20 hours of training claimed for with Best Practice Network.")
    when_i_click("Change the accredited provider")
    when_i_choose_a_provider(niot)
    when_i_click("Continue")
    when_i_click("Continue")
    then_i_should_land_on_the_check_page
  end

  private

  def given_i_sign_in
    visit sign_in_path
    click_on "Sign in using DfE Sign In"
  end

  def given_my_school_has_fully_claimed_for_all_mentors_for_provider(provider)
    school.mentors.find_each do |mentor|
      create(:mentor_training, :submitted, mentor:, provider:, hours_completed: 20)
    end
  end

  def when_i_click(button)
    click_on(button)
  end

  def when_i_click_on_claims
    within(".app-secondary-navigation__list") do
      click_on("Claims")
    end
  end

  def when_i_choose_a_provider(provider)
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
    fill_in("Number of hours", with: hours)
  end

  def then_i_check_my_answers
    expect(page).to have_content("Check your answers")
    expect(page).to have_content("Hours of training")

    within("dl.govuk-summary-list:nth(1)") do
      within(".govuk-summary-list__row:nth(1)") do
        expect(page).to have_content("Accredited provider")
        expect(page).to have_content(bpn.name)
      end

      within(".govuk-summary-list__row:nth(2)") do
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
  end

  def then_i_expect_the_training_hours_for(hours, mentor)
    expect(page).to have_content("Hours of training for #{mentor.full_name}")
    find("#claims-support-claim-mentor-training-form-hours-completed-#{hours}-field").checked?
  end

  def then_i_am_redirectd_to_index_page(claim)
    within(".govuk-notification-banner--success") do
      expect(page).to have_content "Claim added"
    end

    expect(page).to have_content(claim.reference)
  end

  def then_i_see_the_error(message)
    within(".govuk-error-summary") do
      expect(page).to have_content message
    end

    within(".govuk-form-group--error") do
      expect(page).to have_content message
    end
  end

  def when_another_claim_with_same_mentors_has_been_created(mentors)
    claim = create(:claim, :submitted, provider: bpn)
    mentors.each do |mentor|
      create(:mentor_training, claim:, hours_completed: 20, mentor:, provider: bpn)
    end
  end

  def then_i_get_the_reject_page
    expect(page).to have_content "You cannot submit the claim"
  end

  def then_i_should_see_the_message(message)
    expect(page).to have_content(message)
  end

  def then_i_should_land_on_the_check_page
    expect(page).to have_content "Check your answers"
  end

  def then_i_expect_the_mentors_to_be_checked(mentors)
    mentors.each do |mentor|
      has_checked_field?("#claims-claim-mentor-ids-#{mentor.id}-field")
    end
  end

  def then_i_expect_the_provider_to_be_checked(provider)
    has_checked_field?("#claims-claim-provider-form-provider-id-#{provider.id}-field")
  end

  def then_i_expect_to_be_on_the_claims_index_page
    expect(page).to have_current_path(claims_support_school_claims_path(school))
  end
end
