require "rails_helper"

RSpec.describe "Support user signs in with both support and non-support accounts", service: :placements, type: :system do
  scenario do
    given_organisations_exist
    and_i_am_signed_in
    then_i_see_the_organisations_page

    when_i_am_also_a_support_user
    and_i_visit_the_sign_in_path
    then_i_see_the_support_organisations_page
    and_i_see_links_for_the_organisations
  end

  private

  def given_organisations_exist
    @school = create(:placements_school, name: "Hogwarts")
    @provider = create(:placements_provider, name: "Aes Sedai Trust")
  end

  def and_i_am_signed_in
    sign_in_placements_user
  end

  def then_i_see_the_organisations_page
    expect(page).to have_title("Organisations - Manage school placements - GOV.UK")
    expect(page).to have_h1("Organisations")
  end

  def when_i_am_also_a_support_user
    @current_user.update!(type: Placements::SupportUser)
  end

  def and_i_visit_the_sign_in_path
    visit sign_in_path
  end

  def then_i_see_the_support_organisations_page
    expect(page).to have_title("Organisations (2) - Manage school placements - GOV.UK")
    expect(page).to have_h1("Organisations (2)")
    expect(page).to have_link("Add organisation", href: "/support/organisations/new", class: "govuk-button")
  end

  def and_i_see_links_for_the_organisations
    expect(page).to have_link("Hogwarts", href: placements_organisation_path(id: @school.id, type: "School"))
    expect(page).to have_link("Aes Sedai Trust", href: placements_organisation_path(id: @provider.id, type: "Provider"))
  end
end
