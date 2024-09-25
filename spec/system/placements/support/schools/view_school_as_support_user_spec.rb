require "rails_helper"

RSpec.describe "Placements / Organisations / Support user views a School", type: :system do
  let!(:school) { create(:school, :placements) }
  let!(:university) { create(:placements_provider) }

  before do
    Capybara.app_host = "http://#{ENV["PLACEMENTS_HOST"]}"
  end

  scenario "Support user navigates to different organisations on the list" do
    given_i_am_signed_in_as_a_support_user
    when_i_click_on_a_organisation_name(school.name)
    then_i_see_the_school_details
    when_i_navigate_back_to_the_organisations_list
    when_i_click_on_a_organisation_name(university.name)
    then_i_see_the_provider_details
  end

  private

  def given_i_am_signed_in_as_a_support_user
    user = create(:placements_support_user, :colin)
    user_exists_in_dfe_sign_in(user:)
    visit sign_in_path
    click_on "Sign in using DfE Sign In"
  end

  def when_i_click_on_a_organisation_name(name)
    click_on name
  end

  def then_i_see_the_provider_details
    within(".govuk-heading-l") do
      expect(page).to have_content university.name
    end

    within("#organisation-details") do
      expect(page).to have_content "Name"
      expect(page).to have_content "UK provider reference number (UKPRN)"
      expect(page).to have_content "Unique reference number (URN)"
      expect(page).to have_content "Email address"
      expect(page).to have_content "Telephone"
      expect(page).to have_content "Website"
      expect(page).to have_content "Address"
    end
  end

  def when_i_navigate_back_to_the_organisations_list
    within(".app-primary-navigation__list") do
      click_on "Organisations"
    end
  end

  def then_i_see_the_school_details
    within(".govuk-heading-l") do
      expect(page).to have_content school.name
    end

    expect(page).to have_content "Additional details"
    expect(page).to have_content "Special educational needs and disabilities (SEND)"
    expect(page).to have_content "Ofsted"

    within("#organisation-details") do
      expect(page).to have_content "Name"
      expect(page).to have_content "UK provider reference number (UKPRN)"
      expect(page).to have_content "Unique reference number (URN)"
      expect(page).to have_content "Email address"
      expect(page).to have_content "Telephone number"
      expect(page).to have_content "Website"
      expect(page).to have_content "Address"
    end

    within("#additional-details") do
      expect(page).to have_content "Establishment group"
      expect(page).to have_content "Phase"
      expect(page).to have_content "Gender"
      expect(page).to have_content "Age range"
      expect(page).to have_content "Religious character"
      expect(page).to have_content "Admissions policy"
      expect(page).to have_content "Urban or rural"
      expect(page).to have_content "School capacity"
      expect(page).to have_content "Total pupils"
      expect(page).to have_content "Total girls"
      expect(page).to have_content "Total boys"
      expect(page).to have_content "Percentage free school meals"
    end

    within("#send-details") do
      expect(page).to have_content "Special classes"
      expect(page).to have_content "SEND provision"
    end

    within("#ofsted-details") do
      expect(page).to have_content "Rating"
      expect(page).to have_content "Last inspection date"
    end
  end

  def and_i_navigate_to_the_school_details_page
    visit placements_support_school_path(school)
  end
end
