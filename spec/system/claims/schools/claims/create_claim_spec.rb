require "rails_helper"

RSpec.describe "Create claim", type: :system, service: :claims do
  let!(:school) { create(:claims_school, mentors: [mentor1, mentor2]) }
  let!(:anne) do
    create(
      :claims_user,
      :anne,
      user_memberships: [create(:user_membership, organisation: school)],
    )
  end
  let!(:provider) { create(:provider, :best_practice_network) }
  let!(:mentor1) { create(:mentor) }
  let!(:mentor2) { create(:mentor) }

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
    then_i_check_my_answers
    when_i_click("Submit claim")
    # then_i_get_a_claim_reference
  end

  scenario "Anne does not fill the form correctly" do
    when_i_click("Add claim")
    when_i_click("Continue")
    then_i_see_the_error("Select a provider")
    when_i_choose_a_provider
    when_i_click("Continue")
    when_i_click("Continue")
    then_i_see_the_error("Select a mentor")
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

  def then_i_check_my_answers
    expect(page).to have_content("Check your answers")

    within(".govuk-summary-list__row:nth(1)") do
      expect(page).to have_content("Provider")
      expect(page).to have_content(provider.name)
    end

    within(".govuk-summary-list__row:nth(2)") do
      expect(page).to have_content("Mentors")
      expect(page).to have_content(mentor1.full_name)
      expect(page).to have_content(mentor2.full_name)
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
end
