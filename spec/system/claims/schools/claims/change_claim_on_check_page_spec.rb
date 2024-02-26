require "rails_helper"

RSpec.describe "Change claim on check page", type: :system, service: :claims do
  let!(:school) { create(:claims_school, mentors: [mentor1, mentor2]) }
  let!(:anne) do
    create(
      :claims_user,
      :anne,
      user_memberships: [create(:user_membership, organisation: school)],
    )
  end
  let!(:provider1) { create(:provider, :best_practice_network) }
  let!(:provider2) { create(:provider, :niot) }

  let!(:mentor1) { create(:mentor) }
  let!(:mentor2) { create(:mentor) }
  let!(:claim) { create(:claim, school:, provider: provider1, mentors: [mentor1, mentor2]) }

  before do
    user_exists_in_dfe_sign_in(user: anne)
    given_i_sign_in
  end

  scenario "Anne changes the provider on claim on check page" do
    given_i_visit_claim_check_page
    when_i_click_change_provider
    then_i_expect_the_provider_to_be_checked(provider1)
    when_i_change_the_provider
    then_i_expect_the_provider_to_be_checked(provider2)
    when_i_click("Continue")
    then_i_check_my_answers(provider2, [mentor1, mentor2])
    when_i_click("Submit claim")
    # then_i_get_a_claim_reference
  end

  scenario "Anne does not have a provider selected when editing a claim from check page" do
    given_i_visit_claim_check_page
    when_i_click_change_provider
    then_i_expect_the_provider_to_be_checked(provider1)
    when_i_remove_the_provider_from_the_claim
    then_i_reload_the_page
    when_i_click("Continue")
    then_i_see_the_error("Select a provider")
  end

  scenario "Anne changes the mentors on claim on check page" do
    given_i_visit_claim_check_page
    when_i_click_change_mentors
    then_i_expect_the_mentors_to_be_checked([mentor1, mentor2])
    when_i_uncheck_the_mentors([mentor1, mentor2])
    when_i_click("Continue")
    then_i_see_the_error("Select a mentor")
    when_i_check_the_mentor(mentor2)
    when_i_click("Continue")
    then_i_check_my_answers(provider1, [mentor2])
    when_i_click("Submit claim")
    # then_i_get_a_claim_reference
  end

  private

  def given_i_sign_in
    visit sign_in_path
    click_on "Sign in using DfE Sign In"
  end

  def given_i_visit_claim_check_page
    visit check_claims_school_claim_path(school, claim)
  end

  def when_i_click_change_provider
    within(".govuk-summary-list__row:nth(1)") do
      click_on("Change")
    end
  end

  def when_i_click_change_mentors
    within(".govuk-summary-list__row:nth(2)") do
      click_on("Change")
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

  def then_i_check_my_answers(provider, mentors)
    expect(page).to have_content("Check your answers")

    within(".govuk-summary-list__row:nth(1)") do
      expect(page).to have_content("Provider")
      expect(page).to have_content(provider.name)
    end

    within(".govuk-summary-list__row:nth(2)") do
      expect(page).to have_content("Mentors")
      mentors.each do |mentor|
        expect(page).to have_content(mentor.full_name)
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

  def when_i_remove_the_provider_from_the_claim
    claim.provider_id = nil
    claim.save!(validate: false)
  end

  def then_i_reload_the_page
    refresh
  end
end
