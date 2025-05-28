require "rails_helper"

RSpec.describe "Support user signs in without DfE ID", service: :placements, type: :system do
  scenario do
    given_i_sign_in
    then_i_see_the_support_organisations_page
  end

  private

  def given_i_sign_in
    sign_in_placements_support_user(with_dfe_sign_id: false)
  end

  def then_i_see_the_support_organisations_page
    expect(page).to have_title("Organisations (0) - Manage school placements - GOV.UK")
    expect(page).to have_h1("Organisations (0)")
    expect(page).to have_link("Add organisation", href: "/support/organisations/new", class: "govuk-button")
  end
end
