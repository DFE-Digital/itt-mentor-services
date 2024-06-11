require "rails_helper"

RSpec.describe "Placements / Support / Organisations / Support User Selects An Organisation Type To Add",
               type: :system, service: :placements do
  before do
    given_i_sign_in_as_colin
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
    then_i_see_the_title("Enter a school name, URN or postcode")
  end

  scenario "Colin doesn't select an organisation type" do
    and_i_click_continue
    then_i_see_an_error("Select an organisation type")
  end

  private

  def and_there_is_an_existing_user_for(user_name)
    user = create(:placements_support_user, user_name.downcase.to_sym)
    user_exists_in_dfe_sign_in(user:)
  end

  def and_i_visit_the_sign_in_page
    visit sign_in_path
  end

  def and_i_click_sign_in
    click_on "Sign in using DfE Sign In"
  end

  def given_i_sign_in_as_colin
    and_there_is_an_existing_user_for("Colin")
    and_i_visit_the_sign_in_page
    and_i_click_sign_in
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
      expect(page).to have_link "Support users", current: "false"
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
