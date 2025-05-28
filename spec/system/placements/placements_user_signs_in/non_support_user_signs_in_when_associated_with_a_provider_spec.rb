require "rails_helper"

RSpec.describe "Non-support user signs in when associated with a provider", service: :placements, type: :system do
  scenario do
    given_a_provider_exists
    and_i_am_signed_in
    then_i_see_the_find_page
    and_it_is_not_the_support_organisations_page
  end

  private

  def given_a_provider_exists
    @provider = create(:placements_provider, name: "Aes Sedai Trust")
  end

  def and_i_am_signed_in
    sign_in_placements_user(organisations: [@provider])
  end

  def then_i_see_the_find_page
    expect(page).to have_title("Find schools hosting placements - Manage school placements - GOV.UK")
    expect(page).to have_element(:span, text: "Aes Sedai Trust", class: "govuk-heading-s")
    expect(primary_navigation).to have_current_item("Find")
    expect(page).to have_h1("Find schools hosting placements")
  end

  def and_it_is_not_the_support_organisations_page
    expect(page).not_to have_current_path(placements_support_organisations_path)
  end
end
