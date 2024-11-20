require "rails_helper"

RSpec.describe "Placements / Support / Schools / Partner providers / Support user adds a partner provider",
               service: :placements, type: :system do
  include ActiveJob::TestHelper

  let!(:school) { create(:school, :placements) }
  let!(:provider) { create(:placements_provider, name: "Provider 1") }
  let!(:provider_user) { create(:placements_user, providers: [provider]) }

  around do |example|
    perform_enqueued_jobs { example.run }
  end

  before do
    given_i_am_signed_in_as_a_placements_support_user
  end

  scenario "Support user adds a partner provider", :js do
    when_i_visit_the_partner_providers_page_for(school)
    and_i_click_on("Add provider")
    and_i_enter_a_provider_named("Provider 1")
    then_i_see_a_dropdown_item_for("Provider 1")
    when_i_click_the_dropdown_item_for("Provider 1")
    and_i_click_on("Continue")
    then_i_see_the_check_details_page_for_provider("Provider 1")
    when_i_click_on("Confirm and add provider")
    then_i_return_to_partner_provider_index
    and_a_provider_is_listed(provider_name: "Provider 1")
    and_i_see_success_message
    and_a_notification_email_is_sent_to(provider_user)
  end

  scenario "Support user adds a partner provider which already exists", :js do
    given_a_partnership_exists_between(school, provider)
    when_i_visit_the_partner_providers_page_for(school)
    and_i_click_on("Add provider")
    and_i_enter_a_provider_named("Provider 1")
    then_i_see_a_dropdown_item_for("Provider 1")
    when_i_click_the_dropdown_item_for("Provider 1")
    and_i_click_on("Continue")
    then_i_see_an_error("Provider 1 has already been added. Try another provider")
  end

  scenario "Support user submits the search form without selecting a provider", :js do
    when_i_visit_the_add_partner_provider_page
    and_i_click_on("Continue")
    then_i_see_an_error("Enter a provider name, United Kingdom provider number (UKPRN), unique reference number (URN) or postcode")
  end

  scenario "Support user reconsiders selecting a provider", :js do
    when_i_visit_the_partner_providers_page_for(school)
    and_i_click_on("Add provider")
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

  scenario "Support user adds a partner provider, which is not onboarded on the placements service", :js do
    given_the_provider_is_not_onboarded_on_placements_service(provider)
    when_i_visit_the_partner_providers_page_for(school)
    and_i_click_on("Add provider")
    and_i_enter_a_provider_named("Provider 1")
    then_i_see_a_dropdown_item_for("Provider 1")
    when_i_click_the_dropdown_item_for("Provider 1")
    and_i_click_on("Continue")
    then_i_see_the_check_details_page_for_provider("Provider 1")
    when_i_click_on("Confirm and add provider")
    then_i_return_to_partner_provider_index
    and_a_provider_is_listed(provider_name: "Provider 1")
    and_i_see_success_message
    and_a_notification_email_is_not_sent_to(provider_user)
  end

  describe "when I use multiple tabs to add partner providers", :js do
    let(:provider_2) { create(:placements_provider, name: "Provider 2") }
    let(:windows) do
      {
        open_new_window => { provider: },
        open_new_window => { provider: provider_2 },
      }
    end

    it "persists the partner provider details for each tab upon refresh" do
      windows.each do |window, details|
        within_window window do
          when_i_visit_the_partner_providers_page_for(school)
          and_i_click_on("Add provider")
          and_i_enter_a_provider_named(details[:provider].name)
          then_i_see_a_dropdown_item_for(details[:provider].name)
          when_i_click_the_dropdown_item_for(details[:provider].name)
          and_i_click_on("Continue")
          then_i_see_the_check_details_page_for_provider(details[:provider].name)
        end
      end

      # We need this test to be A -> B -> A -> B, so we can't combine the loops.
      # rubocop:disable Style/CombinableLoops
      windows.each do |window, details|
        within_window window do
          when_i_refresh_the_page
          then_the_provider_details_have_not_changed(details[:provider].name)
          when_i_click_on("Confirm and add provider")
          then_i_return_to_partner_provider_index
          and_a_provider_is_listed(provider_name: details[:provider].name)
          and_i_see_success_message
        end
      end
      # rubocop:enable Style/CombinableLoops

      when_i_visit_the_partner_providers_page_for(school)
      then_i_see_my_providers(windows.values)
    end
  end

  private

  def when_i_visit_the_partner_providers_page_for(school)
    visit placements_school_partner_providers_path(school)

    then_i_see_support_navigation_with_organisation_selected
    partner_providers_is_selected_in_secondary_nav
  end

  def when_i_click_on(text)
    click_on text
  end
  alias_method :and_i_click_on, :when_i_click_on

  def and_i_enter_a_provider_named(provider_name)
    fill_in "Add a provider", with: provider_name
  end

  def then_i_see_a_dropdown_item_for(provider_name)
    expect(page).to have_css(".autocomplete__option", text: provider_name, wait: 10)
  end

  def when_i_click_the_dropdown_item_for(provider_name)
    page.find(".autocomplete__option", text: provider_name).click
  end

  def then_i_see_the_check_details_page_for_provider(provider_name)
    expect(page).to have_content("Confirm provider details")
    org_name_row = page.all(".govuk-summary-list__row")[0]
    expect(org_name_row).to have_content(provider_name)
  end

  def then_i_return_to_partner_provider_index
    expect(page.find(".govuk-heading-l")).to have_content("Providers you work with")
  end

  def and_a_provider_is_listed(provider_name:)
    expect(page).to have_content(provider_name)
  end

  def and_i_see_success_message
    expect(page).to have_content "Provider added"
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

  def partner_provider_notification(user)
    ActionMailer::Base.deliveries.find do |delivery|
      delivery.to.include?(user.email) &&
        delivery.subject == "A school has added you"
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
      find_field "Add a provider", with: provider_name
    end
  end

  def then_i_see_support_navigation_with_organisation_selected
    within(".govuk-header__navigation-list") do
      expect(page).to have_link "Organisations"
      expect(page).to have_link "Support users"
    end
  end

  def partner_providers_is_selected_in_secondary_nav
    within(".app-primary-navigation__list") do
      expect(page).to have_link "Organisation details", current: "false"
      expect(page).to have_link "Users", current: "false"
      expect(page).to have_link "Providers", current: "page"
      expect(page).to have_link "Mentors", current: "false"
      expect(page).to have_link "Placements", current: "false"
    end
  end

  def given_the_provider_is_not_onboarded_on_placements_service(provider)
    provider.update!(placements_service: false)
  end

  def when_i_refresh_the_page
    visit current_path
  end

  def then_i_see_my_providers(providers)
    providers.each do |provider|
      expect(page).to have_content(provider[:provider].name)
    end
  end

  alias_method :then_the_provider_details_have_not_changed, :then_i_see_the_check_details_page_for_provider
end
