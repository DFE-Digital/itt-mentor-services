require "rails_helper"

RSpec.describe "Change claim on check page", type: :system, service: :claims do
  let!(:school) { create(:claims_school, mentors: [mentor1, mentor2]) }
  let!(:colin) do
    create(
      :claims_support_user,
      :colin,
      user_memberships: [create(:user_membership, organisation: school)],
    )
  end
  let!(:provider1) { create(:provider, :best_practice_network) }
  let!(:provider2) { create(:provider, :niot) }

  let(:mentor1) { create(:mentor, first_name: "Anne") }
  let(:mentor2) { create(:mentor, first_name: "Joe") }
  let!(:claim) { create(:claim, :internal, school:, provider: provider1) }

  before do
    user_exists_in_dfe_sign_in(user: colin)
    given_i_sign_in
    create(:mentor_training, mentor: mentor1, provider: provider1, claim:, hours_completed: 20)
    create(:mentor_training, mentor: mentor2, provider: provider1, claim:, hours_completed: 12)
  end

  scenario "Colin changes the provider on claim on check page" do
    given_i_visit_claim_support_check_page
    when_i_click_change_provider
    then_i_expect_the_provider_to_be_checked(provider1)
    when_i_change_the_provider
    then_i_expect_the_provider_to_be_checked(provider2)
    when_i_click("Continue")
    then_i_check_my_answers(provider2, [mentor1, mentor2], [20, 12])
    when_i_click("Add claim")
    then_i_am_redirected_to_index_page(claim)
  end

  scenario "Colin does not have a provider selected when editing a claim from check page" do
    given_i_visit_claim_support_check_page
    when_i_click_change_provider
    then_i_expect_the_provider_to_be_checked(provider1)
    when_i_remove_the_provider_from_the_claim
    then_i_reload_the_page
    when_i_click("Continue")
    then_i_see_the_error("Select a provider")
  end

  scenario "Colin changes the mentors on claim on check page" do
    given_i_visit_claim_support_check_page
    when_i_click_change_mentors
    then_i_expect_the_mentors_to_be_checked([mentor1, mentor2])
    when_i_uncheck_the_mentors([mentor1, mentor2])
    when_i_click("Continue")
    then_i_see_the_error("Select a mentor")
    when_i_check_the_mentor(mentor2)
    when_i_click("Continue")
    when_i_click("Continue")
    then_i_see_the_error("Select the number of hours")
    when_i_add_training_hours("20 hours")
    when_i_click("Continue")
    then_i_check_my_answers(provider1, [mentor2], [20])
    when_i_click("Add claim")
    then_i_am_redirected_to_index_page(claim)
  end

  scenario "Colin clicks change mentors the check page and is redirected back to check page" do
    given_i_visit_claim_support_check_page
    when_i_click_change_mentors
    then_i_expect_the_mentors_to_be_checked([mentor1, mentor2])
    when_i_click("Continue")
    then_i_check_my_answers(provider1, [mentor1, mentor2], [20, 12])
  end

  scenario "Colin changes the training hours for a mentor on check page" do
    given_i_visit_claim_support_check_page
    when_i_click_change_training_hours_for_mentor
    then_i_expect_the_training_hours_to_be_selected("20")
    when_i_choose_other_amount
    when_i_click("Continue")
    then_i_see_the_error("Enter the number of hours")
    when_i_choose_other_amount_and_input_hours(6, with_error: true)
    when_i_click("Continue")
    then_i_check_my_answers(provider1, [mentor1, mentor2], [6, 12])
  end

  private

  def given_i_sign_in
    visit sign_in_path
    click_on "Sign in using DfE Sign In"
  end

  def given_i_visit_claim_support_check_page
    visit check_claims_support_school_claim_path(school, claim)
  end

  def when_i_click_change_provider
    within("dl.govuk-summary-list:nth(1)") do
      within(".govuk-summary-list__row:nth(1)") do
        click_on("Change")
      end
    end
  end

  def when_i_click_change_mentors
    within("dl.govuk-summary-list:nth(1)") do
      within(".govuk-summary-list__row:nth(2)") do
        click_on("Change")
      end
    end
  end

  def when_i_click_change_training_hours_for_mentor
    within("dl.govuk-summary-list:nth(2)") do
      within(".govuk-summary-list__row:nth(1)") do
        click_on("Change")
      end
    end
  end

  def when_i_choose_other_amount
    page.choose("Another amount")
  end

  def when_i_choose_other_amount_and_input_hours(hours, with_error: false)
    page.choose("Another amount")

    if with_error
      fill_in("claim-mentor-training-form-custom-hours-completed-field-error", with: hours)
    else
      fill_in("claim-mentor-training-form-custom-hours-completed-field", with: hours)
    end
  end

  def then_i_expect_the_provider_to_be_checked(provider)
    has_checked_field?("#claim-provider-form-provider-id-#{provider.id}-field")
  end

  def then_i_expect_the_mentors_to_be_checked(mentors)
    mentors.each do |mentor|
      has_checked_field?("#claim-mentor-ids-#{mentor.id}-field")
    end
  end

  def when_i_click(button)
    click_on(button)
  end

  def when_i_change_the_provider
    page.choose(provider2.name)
  end

  def when_i_uncheck_the_mentors(mentors)
    mentors.each do |mentor|
      uncheck(mentor.full_name)
    end
  end

  def when_i_check_the_mentor(mentor)
    check(mentor.full_name)
  end

  def when_i_add_training_hours(hours)
    choose(hours)
  end

  def then_i_expect_the_training_hours_to_be_selected(hours)
    find("#claim-mentor-training-form-hours-completed-#{hours}-field").checked?
  end

  def then_i_check_my_answers(provider, mentors, mentor_hours)
    expect(page).to have_content("Check your answers")

    within("dl.govuk-summary-list:nth(1)") do
      within(".govuk-summary-list__row:nth(1)") do
        expect(page).to have_content("Accredited provider")
        expect(page).to have_content(provider.name)
      end

      within(".govuk-summary-list__row:nth(2)") do
        expect(page).to have_content("Mentors")
        mentors.each do |mentor|
          expect(page).to have_content(mentor.full_name)
        end
      end
    end

    within("dl.govuk-summary-list:nth(2)") do
      claim.mentor_trainings.each_with_index do |mentor_training, index|
        expect(page).to have_content(mentor_training.mentor.full_name)
        expect(page).to have_content(mentor_hours[index])
      end
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

  def then_i_am_redirected_to_index_page(claim)
    within(".govuk-notification-banner--success") do
      expect(page).to have_content "Claim added"
    end

    expect(page).to have_content(claim.reload.reference)
  end

  def when_i_remove_the_provider_from_the_claim
    claim.provider_id = nil
    claim.save!(validate: false)
  end

  def then_i_reload_the_page
    refresh
  end
end
