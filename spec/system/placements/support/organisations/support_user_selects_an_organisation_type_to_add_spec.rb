require "rails_helper"

RSpec.describe "Placements / Support / Organisations / Support User Selects An Organisation Type To Add",
               service: :placements, type: :system do
  before do
    given_i_am_signed_in_as_a_support_user
    when_i_click_add_organisation
    then_i_see_support_navigation_with_organisation_selected
  end

  scenario "Colin selects to add an ITT provider" do
    when_i_select_the_radio_option("Teacher training provider")
    and_i_click_continue
    then_i_see_the_title("Enter a provider name, United Kingdom provider number (UKPRN), unique reference number (URN) or postcode")
  end

  scenario "Colin selects to add a school" do
    when_i_select_the_radio_option("School")
    and_i_click_continue
    then_i_see_the_title("Enter a school name, unique reference number (URN) or postcode")
  end

  scenario "Colin doesn't select an organisation type" do
    and_i_click_continue
    then_i_see_an_error("Select an organisation type")
  end

  private

  def and_i_click_continue
    click_on "Continue"
  end

  def when_i_click_add_organisation
    click_on "Add organisation"
  end

  def then_i_see_support_navigation_with_organisation_selected
    within(".govuk-header__navigation-list") do
      expect(page).to have_link "Organisations"
      expect(page).to have_link "Support users"
    end
  end

  def when_i_select_the_radio_option(organisation_type)
    choose(organisation_type)
  end

  def then_i_see_the_title(title_text)
    expect(page.find(".govuk-label--l")).to have_content(title_text)
  end

  def then_i_see_an_error(error_message)
    expect(page.find(".govuk-error-summary")).to have_content(
      "There is a problem",
    )
    expect(page.find(".govuk-error-summary")).to have_content(error_message)
  end
end
