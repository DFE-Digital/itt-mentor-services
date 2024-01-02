require "rails_helper"

RSpec.describe "Placements / Providers / Support User adds a Provider", type: :system, js: true do
  before do
    next_year = Time.current.next_year.year

    stub_request(
      :get,
      "https://www.publish-teacher-training-courses.service.gov.uk/api/public/v1/recruitment_cycles/#{next_year}/providers?filter%5Bis_accredited_body%5D=true",
    ).to_return(
      status: 200,
      body: {
        "data" => [
          {
            "id" => 123,
            "attributes" => {
              name: "Provider 1",
              code: "Prov1",
            },
          },
          {
            "id" => 234,
            "attributes" => {
              name: "Provider 2",
              code: "Prov2",
            },
          },
        ],
      }.to_json,
    )

    stub_request(
      :get,
      "https://www.publish-teacher-training-courses.service.gov.uk/api/public/v1/recruitment_cycles/#{next_year}/providers/Prov1",
    ).to_return(
      status: 200,
      body: {
        "data" => {
          "id" => 123,
          "attributes" => {
            name: "Provider 1",
            code: "Prov1",
          },
        },
      }.to_json,
    )

    given_i_sign_in_as_colin
  end
  after { Capybara.app_host = nil }

  scenario "Colin adds a new Provider", js: true do
    when_i_visit_the_add_provider_page
    and_i_enter_a_provider_named("Provider 1")
    then_i_see_a_dropdown_item_for("Provider 1")
    when_i_click_the_dropdown_item_for("Provider 1")
    and_i_click_continue
    then_i_see_the_check_details_page_for_provider("Provider 1")
    when_i_click_add_organisation
    then_i_return_to_support_organisations_index
    and_a_provider_code_is_listed(provider_code: "Prov1")
  end

  scenario "Colin adds a Provider which already exists", js: true do
    given_a_provider_already_exists(code: "Prov1")
    when_i_visit_the_add_provider_page
    and_i_enter_a_provider_named("Provider 1")
    then_i_see_a_dropdown_item_for("Provider 1")
    when_i_click_the_dropdown_item_for("Provider 1")
    and_i_click_continue
    then_i_see_an_error("This provider has already been added. Try another provider")
  end

  scenario "Colin submits the search form without selecting a provider", js: true do
    when_i_visit_the_add_provider_page
    and_i_click_continue
    then_i_see_an_error("Enter a provider name, UKPRN, URN or postcode")
  end

  private

  def given_i_am_on_the_placements_site
    Capybara.app_host = "http://#{ENV["PLACEMENTS_HOST"]}"
  end

  def and_there_is_an_existing_persona_for(persona_name)
    create(:persona, persona_name.downcase.to_sym, service: :placements)
  end

  def and_i_visit_the_personas_page
    visit personas_path
  end

  def and_i_click_sign_in_as(persona_name)
    click_on "Sign In as #{persona_name}"
  end

  def when_i_visit_the_add_provider_page
    visit new_placements_support_provider_path
  end

  def given_i_sign_in_as_colin
    given_i_am_on_the_placements_site
    and_there_is_an_existing_persona_for("Colin")
    and_i_visit_the_personas_page
    and_i_click_sign_in_as("Colin")
  end

  def and_i_enter_a_provider_named(provider_name)
    fill_in "accredited-provider-search-form-query-field", with: provider_name
  end

  def then_i_see_a_dropdown_item_for(provider_name)
    expect(page).to have_css(".autocomplete__option", text: provider_name)
  end

  def when_i_click_the_dropdown_item_for(provider_name)
    page.find(".autocomplete__option", text: provider_name).click
  end

  def and_i_click_continue
    click_on "Continue"
  end

  def then_i_see_the_check_details_page_for_provider(provider_name)
    expect(page).to have_css(".govuk-caption-l", text: "Add organisation")
    expect(page).to have_content("Check your answers")
    org_name_row = page.all(".govuk-summary-list__row")[0]
    expect(org_name_row).to have_content(provider_name)
  end

  def when_i_click_add_organisation
    click_on "Add organisation"
  end

  def then_i_return_to_support_organisations_index
    expect(page).to have_content("Organisations")
  end

  def given_a_provider_already_exists(code:)
    create(:provider, provider_code: code)
  end

  def then_i_see_an_error(error_message)
    # Error summary
    expect(page.find(".govuk-error-summary")).to have_content(
      "There is a problem",
    )
    expect(page.find(".govuk-error-summary")).to have_content(error_message)
    # Error above input
    expect(page.find(".govuk-error-message")).to have_content(error_message)
  end

  def and_a_provider_code_is_listed(provider_code:)
    expect(page).to have_content(provider_code)
  end
end
