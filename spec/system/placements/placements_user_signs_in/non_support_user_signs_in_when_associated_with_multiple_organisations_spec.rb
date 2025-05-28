require "rails_helper"

RSpec.describe "Non-support user signs in when associated with multiple organisations", service: :placements, type: :system do
  scenario do
    given_a_school_and_a_provider_exists
    and_i_am_signed_in
    then_i_see_the_organisations_page
    and_i_see_links_for_my_organisations
    and_it_is_not_the_support_organisations_page
  end

  private

  def given_a_school_and_a_provider_exists
    @school = create(:placements_school, name: "Hogwarts")
    @provider = create(:placements_provider, name: "Aes Sedai Trust")
  end

  def and_i_am_signed_in
    sign_in_placements_user(organisations: [@school, @provider])
  end

  def then_i_see_the_organisations_page
    expect(page).to have_title("Organisations - Manage school placements - GOV.UK")
    expect(page).to have_h1("Organisations")
  end

  def and_i_see_links_for_my_organisations
    expect(page).to have_link("Hogwarts", href: placements_organisation_path(id: @school.id, type: "School"))
    expect(page).to have_link("Aes Sedai Trust", href: placements_organisation_path(id: @provider.id, type: "Provider"))
  end

  def and_it_is_not_the_support_organisations_page
    expect(page).not_to have_current_path(placements_support_organisations_path)
  end
end
