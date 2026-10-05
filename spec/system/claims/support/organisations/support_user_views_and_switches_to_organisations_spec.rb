require "rails_helper"

RSpec.describe "Support user views and switches to organisations", service: :claims, type: :system do
  let!(:school) { create(:school, :claims, name: "Manchester School", postcode: "M1234") }
  let!(:provider) { create(:claims_provider, name: "London Provider", postcode: "L5678") }

  before do
    create(:claims_provider, name: "Excluded Code Provider", code: "1YF")
    create(:claims_provider, name: "Unaccredited Provider", accredited: false)
  end

  scenario "I view schools and providers together and switch to each" do
    given_i_am_signed_in_as_support_user
    then_i_see_the_school_tagged_as_a_school
    and_i_see_the_provider_tagged_as_a_provider
    and_i_do_not_see_the_unaccredited_provider
    when_i_search_for("London")
    then_i_see_only_the_provider
    when_i_click_on("London Provider")
    then_i_see_the_provider_claims_page
  end

  scenario "I switch to a school" do
    given_i_am_signed_in_as_support_user
    when_i_click_on("Manchester School")
    then_i_see_the_school_claims_page
  end

  private

  def given_i_am_signed_in_as_support_user
    user = create(:claims_support_user, :colin)
    user_exists_in_dfe_sign_in(user:)
    visit sign_in_path
    click_on "Sign in using DfE Sign In"
  end

  def then_i_see_the_school_tagged_as_a_school
    expect(page).to have_content("Organisations (3)")
    expect(organisation_item("Manchester School")).to have_css(".govuk-tag--yellow", text: "School")
  end

  def and_i_see_the_provider_tagged_as_a_provider
    expect(organisation_item("London Provider")).to have_css(".govuk-tag--blue", text: "Provider")
    expect(organisation_item("Excluded Code Provider")).to have_css(".govuk-tag--blue", text: "Provider")
  end

  def and_i_do_not_see_the_unaccredited_provider
    expect(page).not_to have_content("Unaccredited Provider")
  end

  def when_i_search_for(term)
    fill_in "Search by organisation name or postcode", with: term
    click_on "Search"
  end

  def then_i_see_only_the_provider
    expect(page).to have_content("London Provider")
    expect(page).not_to have_content("Manchester School")
  end

  def when_i_click_on(name)
    click_on name
  end

  def then_i_see_the_provider_claims_page
    expect(page).to have_current_path(claims_provider_claims_path(provider), ignore_query: true)
  end

  def then_i_see_the_school_claims_page
    expect(page).to have_current_path(claims_school_claims_path(school), ignore_query: true)
  end

  def organisation_item(name)
    find(".organisation-search-results__item", text: name)
  end
end
