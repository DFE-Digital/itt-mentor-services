require "rails_helper"

RSpec.describe "Support user uses a deep link", service: :placements, type: :system do
  scenario do
    given_i_have_an_account
    when_i_visit_the_support_organisations_path
    then_i_am_redirected_to_the_sign_in_page

    when_i_click_on_sign_in_using_dfe_sign_in
    then_i_am_redirected_to_the_support_organisations_page
  end

  private

  def given_i_have_an_account
    sign_in_placements_support_user(sign_in: false)
  end

  def when_i_visit_the_support_organisations_path
    visit placements_support_organisations_path
  end

  def then_i_am_redirected_to_the_sign_in_page
    expect(page).to have_title("Manage school placements - GOV.UK")
    expect(page).to have_h1("Sign in to Manage school placements")
  end

  def when_i_click_on_sign_in_using_dfe_sign_in
    click_on "Sign in using DfE Sign In"
  end

  def then_i_am_redirected_to_the_support_organisations_page
    expect(page).to have_title("Organisations (0) - Manage school placements - GOV.UK")
    expect(page).to have_h1("Organisations (0)")
    expect(page).to have_link("Add organisation", href: "/support/organisations/new", class: "govuk-button")
  end
end
