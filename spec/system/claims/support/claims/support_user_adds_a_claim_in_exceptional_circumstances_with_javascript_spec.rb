require "rails_helper"

RSpec.describe "Support user adds a claim in exceptional circumstances with javascript", :js, service: :claims, type: :system do
  scenario do
    given_a_closed_claim_window_exists
    and_schools_exist
    and_providers_exist
    and_i_am_signed_in
    and_i_have_reached_the_school_step

    when_i_search_for_a_school_that_is_not_onboarded
    then_i_see_the_not_onboarded_school_as_a_suggestion

    when_i_search_for_a_school_that_does_not_exist
    then_i_see_no_school_results

    when_i_choose_the_not_onboarded_school
    and_i_click_on_continue
    then_i_see_the_school_onboarding_and_eligibility_page

    when_i_confirm_the_school_is_onboarded_and_made_eligible
    and_i_click_on_continue
    then_i_see_the_provider_page

    when_i_search_for_a_provider
    then_i_see_only_providers_eligible_for_the_claim_window_academic_year_as_suggestions

    when_i_choose_the_accredited_provider
    and_i_click_on_continue
    then_i_see_the_no_mentors_page_for_the_provider
  end

  private

  def given_a_closed_claim_window_exists
    @past_claim_window = create(:claim_window, :historic)
  end

  def and_schools_exist
    @onboarded_school = create(:claims_school, name: "Springfield Elementary", region: regions(:inner_london),
                                               eligibilities: [build(:eligibility, claim_window: @past_claim_window)])
    @not_onboarded_school = create(:school, name: "Shelbyville Elementary", claims_service: false, region: regions(:inner_london))
  end

  def and_providers_exist
    other_academic_year = AcademicYear.for_date(@past_claim_window.academic_year.ends_on + 1.day)
    @eligible_provider = create(:provider, :best_practice_network, accredited: false)
    @eligible_provider.eligibilities.create!(academic_year: @past_claim_window.academic_year)
    @ineligible_provider = create(:provider, name: "Ineligible Provider", code: "INE", accredited: true)
    @ineligible_provider.eligibilities.destroy_all
    @next_year_provider = create(:provider, name: "Next Year Provider", code: "NXT", accredited: true)
    @next_year_provider.eligibilities.destroy_all
    @next_year_provider.eligibilities.create!(academic_year: other_academic_year)
  end

  def and_i_am_signed_in
    sign_in_claims_support_user
    expect(page).to have_h1("Organisations (1)")
  end

  def and_i_have_reached_the_school_step
    visit claims_support_claims_path
    click_on "Add exceptional claim"
    check "I confirm that this claim is being added under exceptional circumstances"
    click_on "Continue"
    choose "#{@past_claim_window.academic_year_name} academic year"
    click_on "Continue"
  end

  def when_i_search_for_a_school_that_is_not_onboarded
    fill_in "Enter the school for this claim", with: "Shelbyville"
  end

  def then_i_see_the_not_onboarded_school_as_a_suggestion
    expect(page).to have_css(".autocomplete__option", text: "Shelbyville Elementary", wait: 10)
    expect(page).to have_no_css(".autocomplete__option", text: "Springfield Elementary")
  end

  def when_i_search_for_a_school_that_does_not_exist
    fill_in "Enter the school for this claim", with: "Hogwarts"
  end

  def then_i_see_no_school_results
    expect(page).to have_css(".autocomplete__option", text: "No results found", wait: 10)
  end

  def when_i_choose_the_not_onboarded_school
    fill_in "Enter the school for this claim", with: "Shelbyville"
    find(".autocomplete__option", text: "Shelbyville Elementary", wait: 10).click
  end

  def and_i_click_on_continue
    click_on "Continue"
  end

  def then_i_see_the_school_onboarding_and_eligibility_page
    expect(page).to have_h1("Shelbyville Elementary is not eligible to claim")
  end

  def when_i_confirm_the_school_is_onboarded_and_made_eligible
    check "I confirm that Shelbyville Elementary should be onboarded to the claims service and made eligible to claim for the #{@past_claim_window.academic_year_name} academic year"
  end

  def then_i_see_the_provider_page
    expect(page).to have_element(:label, text: "Enter the accredited provider for this claim", class: "govuk-label govuk-label--l")
  end

  def when_i_search_for_a_provider
    fill_in "Enter the accredited provider for this claim", with: "Provider"
    fill_in "Enter the accredited provider for this claim", with: "Best Practice"
  end

  def then_i_see_only_providers_eligible_for_the_claim_window_academic_year_as_suggestions
    expect(page).to have_css(".autocomplete__option", text: "Best Practice Network", wait: 10)
    fill_in "Enter the accredited provider for this claim", with: "Ineligible"
    expect(page).to have_css(".autocomplete__option", text: "No results found", wait: 10)
    fill_in "Enter the accredited provider for this claim", with: "Next Year"
    expect(page).to have_css(".autocomplete__option", text: "No results found", wait: 10)
    fill_in "Enter the accredited provider for this claim", with: "Best Practice"
  end

  def when_i_choose_the_accredited_provider
    find(".autocomplete__option", text: "Best Practice Network", wait: 10).click
  end

  def then_i_see_the_no_mentors_page_for_the_provider
    expect(page).to have_h1("No mentors for Best Practice Network")
    expect(page).to have_link("Add a mentor to the school")
  end
end
