require "rails_helper"

RSpec.describe "Support user views an empty partner providers index page",
               service: :placements,
               type: :system do
  scenario do
    given_a_school_exists
    and_i_am_signed_in

    when_i_am_on_the_organisations_index_page
    and_i_select_springfield_elementary
    and_i_navigate_to_providers
    then_i_see_the_providers_you_work_with_page
    and_i_see_no_providers
  end

  private

  def given_a_school_exists
    @springfield_elementary_school = create(
      :placements_school,
      name: "Springfield Elementary",
      address1: "Westgate Street",
      address2: "Hackney",
      postcode: "E8 3RL",
      group: "Local authority maintained schools",
      phase: "Primary",
      gender: "Mixed",
      minimum_age: 3,
      maximum_age: 11,
      religious_character: "Does not apply",
      admissions_policy: "Not applicable",
      urban_or_rural: "(England/Wales) Urban major conurbation",
      percentage_free_school_meals: 15,
      rating: "Outstanding",
    )
  end

  def and_i_am_signed_in
    sign_in_placements_support_user
  end

  def when_i_am_on_the_organisations_index_page
    expect(page).to have_title("Organisations (1) - Manage school placements - GOV.UK")
    expect(page).to have_h1("Organisations (1)")
  end

  def and_i_select_springfield_elementary
    click_on "Springfield Elementary"
  end

  def and_i_navigate_to_providers
    within ".app-primary-navigation__nav" do
      click_on "Providers"
    end
  end

  def then_i_see_the_providers_you_work_with_page
    expect(page).to have_title("Providers you work with - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Providers")
    expect(page).to have_h1("Providers you work with", class: "govuk-heading-l")
    expect(page).to have_element(
      :p,
      text: "Add providers to be able to assign them to your placements.",
      class: "govuk-body",
    )
    expect(page).to have_link("Add provider", class: "govuk-button")
  end

  def and_i_see_no_providers
    expect(page).to have_element(
      :p,
      text: "There are no providers for Springfield Elementary",
      class: "govuk-body",
    )
  end
end
