require "rails_helper"

RSpec.describe "User without partnerships views the provider index",
               service: :placements, type: :system do
  scenario do
    given_i_am_signed_in

    when_i_click_on_providers_in_the_navigation_menu
    then_i_see_the_providers_index_page
    and_i_see_the_empty_provider_index
  end

  private

  def given_i_am_signed_in
    @school = create(:placements_school)
    given_i_am_signed_in_as_a_placements_user(organisations: [@school])
  end

  def when_i_click_on_providers_in_the_navigation_menu
    within ".app-primary-navigation__nav" do
      click_on "Providers"
    end
  end

  def then_i_see_the_providers_index_page
    page.find(".app-primary-navigation__nav").click_on("Providers")
    expect(primary_navigation).to have_current_item("Providers")

    expect(page).to have_title("Providers you work with - Manage school placements - GOV.UK")
    expect(page).to have_h1("Providers you work with")
  end

  def and_i_see_the_empty_provider_index
    expect(primary_navigation).to have_current_item("Providers")
    expect(page).to have_title("Providers you work with - Manage school placements - GOV.UK")

    expect(page).to have_h1("Providers you work with")
    expect(page).to have_element(:p, text: "Add providers to be able to assign them to your placements.", class: "govuk-body")
    expect(page).to have_link("Add provider", href: "/schools/#{@school.id}/partner_providers/new")
    expect(page).to have_element(:p, text: "There are no providers for #{@school.name}.", class: "govuk-body")
  end
end
