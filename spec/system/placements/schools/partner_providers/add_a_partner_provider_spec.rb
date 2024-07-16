require "rails_helper"

RSpec.describe "Placements / Schools / Partner providers / Add a partner provider",
               service: :placements, type: :system do
  include ActiveJob::TestHelper

  around do |example|
    perform_enqueued_jobs { example.run }
  end

  let!(:school) { create(:school, :placements) }
  let!(:provider) { create(:placements_provider, name: "Provider 1") }
  let!(:provider_user) { create(:placements_user, providers: [provider]) }

  before do
    given_i_sign_in_as_anne
  end

  scenario "User adds a partner provider", :js, retry: 3 do
    when_i_view_the_partner_providers_page
    and_i_click_on("Add partner provider")
    and_i_enter_a_provider_named("Provider 1")
    then_i_see_a_dropdown_item_for("Provider 1")
    when_i_click_the_dropdown_item_for("Provider 1")
    and_i_click_on("Continue")
    then_i_see_the_check_details_page_for_provider("Provider 1")
    when_i_click_on("Add partner provider")
    then_i_return_to_partner_provider_index
    and_a_provider_is_listed(provider_name: "Provider 1")
    and_i_see_success_message
    and_a_notification_email_is_sent_to(provider_user)
  end

  scenario "User adds a partner provider which already exists", :js, retry: 3 do
    given_a_partnership_exists_between(school, provider)
    when_i_view_the_partner_providers_page
    and_i_click_on("Add partner provider")
    and_i_enter_a_provider_named("Provider 1")
    then_i_see_a_dropdown_item_for("Provider 1")
    when_i_click_the_dropdown_item_for("Provider 1")
    and_i_click_on("Continue")
    then_i_see_an_error("Provider 1 has already been added. Try another provider")
  end

  scenario "User submits the search form without selecting a provider", :js, retry: 3 do
    when_i_visit_the_add_partner_provider_page
    and_i_click_on("Continue")
    then_i_see_an_error("Enter a provider name, United Kingdom provider number (UKPRN), unique reference number (URN) or postcode")
  end

  scenario "User reconsiders selecting a provider", :js, retry: 3 do
    when_i_view_the_partner_providers_page
    and_i_click_on("Add partner provider")
    and_i_enter_a_provider_named("Provider 1")
    then_i_see_a_dropdown_item_for("Provider 1")
    when_i_click_the_dropdown_item_for("Provider 1")
    and_i_click_on("Continue")
    then_i_see_the_check_details_page_for_provider("Provider 1")
    when_i_click_on("Back")
    then_i_see_the_search_input_pre_filled_with("Provider 1")
    and_i_click_on("Continue")
    then_i_see_the_check_details_page_for_provider("Provider 1")
  end

  scenario "User adds a partner provider, which is not onboarded on the placements service", :js, retry: 3 do
    given_the_provider_is_not_onboarded_on_placements_service(provider)
    when_i_view_the_partner_providers_page
    and_i_click_on("Add partner provider")
    and_i_enter_a_provider_named("Provider 1")
    then_i_see_a_dropdown_item_for("Provider 1")
    when_i_click_the_dropdown_item_for("Provider 1")
    and_i_click_on("Continue")
    then_i_see_the_check_details_page_for_provider("Provider 1")
    when_i_click_on("Add partner provider")
    then_i_return_to_partner_provider_index
    and_a_provider_is_listed(provider_name: "Provider 1")
    and_i_see_success_message
    and_a_notification_email_is_not_sent_to(provider_user)
  end

  private

  def given_i_sign_in_as_anne
    user = create(:placements_user, :anne)
    create(:user_membership, user:, organisation: school)
    user_exists_in_dfe_sign_in(user:)
    visit sign_in_path
    click_on "Sign in using DfE Sign In"
  end

  def when_i_view_the_partner_providers_page
    visit placements_school_partner_providers_path(school)

    expect_partner_providers_to_be_selected_in_primary_navigation
  end

  def when_i_click_on(text)
    click_on text
  end
  alias_method :and_i_click_on, :when_i_click_on

  def and_i_enter_a_provider_named(provider_name)
    fill_in "placements-add-partnership-wizard-partnership-step-id-field", with: provider_name
  end

  def then_i_see_a_dropdown_item_for(provider_name)
    expect(page).to have_css(".autocomplete__option", text: provider_name)
  end

  def when_i_click_the_dropdown_item_for(provider_name)
    page.find(".autocomplete__option", text: provider_name).click
  end

  def then_i_see_the_check_details_page_for_provider(provider_name)
    expect(page).to have_css(".govuk-caption-l", text: "Add partner provider")
    expect(page).to have_content("Check your answers")
    org_name_row = page.all(".govuk-summary-list__row")[0]
    expect(org_name_row).to have_content(provider_name)
  end

  def then_i_return_to_partner_provider_index
    expect(page.find(".govuk-heading-l")).to have_content("Partner providers")
  end

  def and_a_provider_is_listed(provider_name:)
    expect(page).to have_content(provider_name)
  end

  def and_i_see_success_message
    expect(page).to have_content "Partner provider added"
  end

  def given_a_partnership_exists_between(school, provider)
    create(:placements_partnership, school:, provider:)
  end
  alias_method :and_a_partnership_exists_between, :given_a_partnership_exists_between

  def then_i_see_an_error(error_message)
    # Error summary
    expect(page.find(".govuk-error-summary")).to have_content(
      "There is a problem",
    )
    expect(page.find(".govuk-error-summary")).to have_content(error_message)
    # Error above input
    expect(page.find(".govuk-error-message")).to have_content(error_message)
  end

  def when_i_visit_the_add_partner_provider_page
    visit new_add_partner_provider_placements_school_partner_providers_path(school)
  end

  def given_i_have_completed_the_form_to_select(provider:)
    params = {
      "partnership" => { provider_id: provider.id, provider_name: provider.name },
      school_id: school.id,
    }
    visit check_placements_school_partner_providers_path(params)
  end

  def partner_provider_notification(user)
    ActionMailer::Base.deliveries.find do |delivery|
      delivery.to.include?(user.email) &&
        delivery.subject == "A school has added your organisation to its list of partner providers"
    end
  end

  def and_a_notification_email_is_sent_to(user)
    email = partner_provider_notification(user)

    expect(email).not_to be_nil
  end

  def and_a_notification_email_is_not_sent_to(user)
    email = partner_provider_notification(user)

    expect(email).to be_nil
  end

  def then_i_see_the_search_input_pre_filled_with(provider_name)
    within(".autocomplete__wrapper") do
      expect(page.find("#placements-add-partnership-wizard-partnership-step-id-field").value).to eq(provider_name)
    end
  end

  def expect_partner_providers_to_be_selected_in_primary_navigation
    nav = page.find(".app-primary-navigation__nav")

    within(nav) do
      expect(page).to have_link "Placements", current: "false"
      expect(page).to have_link "Mentors", current: "false"
      expect(page).to have_link "Users", current: "false"
      expect(page).to have_link "Organisation details", current: "false"
      expect(page).to have_link "Partner providers", current: "page"
    end
  end

  def given_the_provider_is_not_onboarded_on_placements_service(provider)
    provider.update!(placements_service: false)
  end
end
