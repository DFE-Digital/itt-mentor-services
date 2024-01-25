require "rails_helper"

RSpec.describe "Placements / Support / Organisations / Support User Selects An Organisation Type To Add",
               type: :system, service: :placements do
  before do
    given_i_sign_in_as_colin
    when_i_click_add_organisation
    then_i_see_support_navigation_with_organisation_selected
  end

  scenario "Colin selects to add an ITT provider" do
    when_i_select_the_radio_option("ITT provider")
    and_i_click_continue
    then_i_see_the_title("Enter a provider name, UKPRN, URN or postcode")
  end

  scenario "Colin selects to add a school" do
    when_i_select_the_radio_option("School")
    and_i_click_continue
    then_i_see_the_title("Enter a school name, URN or postcode")
  end

  scenario "Colin doesn't select an organisation type" do
    and_i_click_continue
    then_i_see_an_error("Select an organisation type")
  end

  private

  def and_there_is_an_existing_persona_for(persona_name)
    create(:persona, persona_name.downcase.to_sym, service: :placements)
  end

  def and_i_visit_the_personas_page
    visit personas_path
  end

  def and_i_click_sign_in_as(persona_name)
    click_on "Sign In as #{persona_name}"
  end

  def given_i_sign_in_as_colin
    and_there_is_an_existing_persona_for("Colin")
    and_i_visit_the_personas_page
    and_i_click_sign_in_as("Colin")
  end

  def and_i_click_continue
    click_on "Continue"
  end

  def when_i_click_add_organisation
    click_on "Add organisation"
  end

  def then_i_see_support_navigation_with_organisation_selected
    within(".app-primary-navigation__nav") do
      expect(page).to have_link "Organisations", current: "page"
      expect(page).to have_link "Users", current: "false"
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
