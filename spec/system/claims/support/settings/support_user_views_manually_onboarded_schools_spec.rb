require "rails_helper"

RSpec.describe "Support user views manually onboarded schools", service: :claims, type: :system do
  scenario do
    given_manually_onboarded_schools_exist
    and_i_am_signed_in
    when_i_navigate_to_the_settings_index_page
    then_i_see_the_manually_onboarded_schools_link

    when_i_click_on_the_manually_onboarded_schools_link
    then_i_see_the_manually_onboarded_schools_page
  end

  private

  def given_manually_onboarded_schools_exist
    @current_academic_year = AcademicYear.current
    @previous_academic_year = AcademicYear.current.previous

    @current_claim_window = create(:claim_window, :current, academic_year: @current_academic_year)
    @previous_claim_window = create(:claim_window, :historic, academic_year: @previous_academic_year)

    @london_onboarding_user = create(:claims_support_user, first_name: "London", last_name: "Onboarder User", email: "london_onboarder@education.gov.uk")
    @london_school = create(:claims_school, name: "London School", urn: 111_111, manually_onboarded_by: @london_onboarding_user)
    create(:eligibility, school: @london_school, academic_year: @current_academic_year)
    create(:eligibility, school: @london_school, academic_year: @previous_academic_year)

    @guildford_onboarding_user = create(:claims_support_user, first_name: "Guildford", last_name: "Onboarder User", email: "guildford_onboarder@education.gov.uk")
    @guildford_school = create(:claims_school, name: "Guildford School", urn: 222_222, manually_onboarded_by: @guildford_onboarding_user)
    create(:eligibility, school: @guildford_school, academic_year: @current_academic_year)
  end

  def and_i_am_signed_in
    sign_in_claims_support_user
  end

  def when_i_navigate_to_the_settings_index_page
    within(primary_navigation) do
      click_on "Settings"
    end
  end

  def then_i_see_the_manually_onboarded_schools_link
    expect(page).to have_link("View manually onboarded schools", href: "/support/manually_onboarded_schools")
  end

  def when_i_click_on_the_manually_onboarded_schools_link
    click_on "View manually onboarded schools"
  end

  def then_i_see_the_manually_onboarded_schools_page
    expect(page).to have_title("Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_link("Settings", href: "/support/settings")
    expect(page).to have_h1("Manually onboarded schools", class: "govuk-heading-l")
    expect(page).to have_table_row({
      "School name" => "London School",
      "Onboarded by" => "London Onboarder User",
      "Eligible to claim dates" => "#{I18n.l(@current_claim_window.starts_on, format: :long)} to #{I18n.l(@current_claim_window.ends_on, format: :long)} (current) #{I18n.l(@previous_claim_window.starts_on, format: :long)} to #{I18n.l(@previous_claim_window.ends_on, format: :long)}",
    })
    expect(page).to have_table_row({
      "School name" => "Guildford School",
      "Onboarded by" => "Guildford Onboarder User",
      "Eligible to claim dates" => "#{I18n.l(@current_claim_window.starts_on, format: :long)} to #{I18n.l(@current_claim_window.ends_on, format: :long)} (current)",
    })
  end
end
