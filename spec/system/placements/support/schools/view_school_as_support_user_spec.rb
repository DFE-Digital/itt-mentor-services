require "rails_helper"

RSpec.describe "Placements / Organisations / Support user views a School", type: :system do
  let!(:school) { create(:school, :placements) }
  let!(:university) { create(:placements_provider) }

  before do
    Capybara.app_host = "http://#{ENV["PLACEMENTS_HOST"]}"
  end

  scenario "Support user navigates to different organisations on the list" do
    given_i_am_signed_in_as_a_placements_support_user
    when_i_click_on_a_organisation_name(school.name)
    and_i_click_on("Organisation details")
    then_i_see_the_school_details
    when_i_navigate_back_to_the_organisations_list
    when_i_click_on_a_organisation_name(university.name)
    and_i_click_on("Organisation details")
    then_i_see_the_provider_details
  end

  private

  def when_i_click_on_a_organisation_name(name)
    click_on name
  end

  def then_i_see_the_provider_details
    within("#organisation-details") do
      expect(page).to have_text university.name
      expect(page).to have_text "Name"
      expect(page).to have_text "UK provider reference number (UKPRN)"
      expect(page).to have_text "Unique reference number (URN)"
      expect(page).to have_text "Email address"
      expect(page).to have_text "Telephone"
      expect(page).to have_text "Website"
      expect(page).to have_text "Address"
    end
  end

  def when_i_navigate_back_to_the_organisations_list
    within(".govuk-service-navigation__list") do
      click_on "Organisations"
    end
  end

  def then_i_see_the_school_details
    within(".govuk-heading-l") do
      expect(page).to have_text school.name
    end

    expect(page).to have_text "Additional details"
    expect(page).to have_text "Special educational needs and disabilities (SEND)"
    expect(page).to have_text "Ofsted"

    within("#organisation-details") do
      expect(page).to have_text "Name"
      expect(page).to have_text "UK provider reference number (UKPRN)"
      expect(page).to have_text "Unique reference number (URN)"
      expect(page).to have_text "Email address"
      expect(page).to have_text "Telephone number"
      expect(page).to have_text "Website"
      expect(page).to have_text "Address"
    end

    within("#additional-details") do
      expect(page).to have_text "Establishment group"
      expect(page).to have_text "Phase"
      expect(page).to have_text "Gender"
      expect(page).to have_text "Age range"
      expect(page).to have_text "Religious character"
      expect(page).to have_text "Admissions policy"
      expect(page).to have_text "Urban or rural"
      expect(page).to have_text "School capacity"
      expect(page).to have_text "Total pupils"
      expect(page).to have_text "Total girls"
      expect(page).to have_text "Total boys"
      expect(page).to have_text "Percentage free school meals"
    end

    within("#send-details") do
      expect(page).to have_text "Special classes"
      expect(page).to have_text "SEND provision"
    end

    within("#ofsted-details") do
      expect(page).to have_text "Rating"
      expect(page).to have_text "Last inspection date"
    end
  end

  def and_i_navigate_to_the_school_details_page
    visit placements_support_school_path(school)
  end

  def and_i_click_on(text)
    click_on text
  end
end
