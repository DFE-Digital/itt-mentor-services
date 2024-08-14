require "rails_helper"

RSpec.describe "Placements / Support / Schools / Partner providers / Support user adds a partner provider without javascript",
               service: :placements, type: :system do
  include ActiveJob::TestHelper

  around do |example|
    perform_enqueued_jobs { example.run }
  end

  let!(:school) { create(:placements_school) }
  let!(:provider) { create(:provider, :placements, name: "Manchester 1") }
  let!(:provider_user) { create(:placements_user, providers: [provider]) }

  before do
    create(:provider, name: "Manchester 2")
    create(:provider, :placements, name: "London")
    create(:claims_provider, name: "Claims")

    given_i_am_signed_in_as_a_support_user
  end

  scenario "Support user adds a partner provider" do
    when_i_visit_the_add_partner_provider_page_for(school)
    and_i_enter_a_provider_named("Manch")
    and_i_click_on("Continue")
    then_i_see_list_of_placements_providers
    when_i_choose("Manchester 1")
    and_i_click_on("Continue")
    then_i_see_the_check_details_page_for_provider("Manchester 1")
    and_i_click_on("Add partner provider")
    then_i_return_to_partner_provider_index
    and_a_provider_is_listed(provider_name: "Manchester 1")
    and_i_see_success_message
    and_a_notification_email_is_sent_to(provider_user)
  end

  scenario "Support user adds a partner provider which already exists" do
    given_a_partnership_exists_between(school, provider)
    when_i_visit_the_add_partner_provider_page_for(school)
    and_i_enter_a_provider_named("Manch")
    and_i_click_on("Continue")
    then_i_see_list_of_placements_providers
    when_i_choose("Manchester 1")
    and_i_click_on("Continue")
    then_i_see_an_error("Manchester 1 has already been added. Try another provider")
  end

  scenario "Support user submits the search form without selecting a provider" do
    when_i_visit_the_add_partner_provider_page_for(school)
    and_i_click_on("Continue")
    then_i_see_an_error("Enter a provider name, United Kingdom provider number (UKPRN), unique reference number (URN) or postcode")
  end

  scenario "Support user submits the options form without selecting a provider" do
    when_i_visit_the_add_partner_provider_page_for(school)
    and_i_enter_a_provider_named("Manch")
    and_i_click_on("Continue")
    then_i_see_list_of_placements_providers
    and_i_click_on("Continue")
    then_i_see_an_error("Select a provider")
  end

  scenario "Support user reconsiders selecting a provider" do
    when_i_visit_the_add_partner_provider_page_for(school)
    and_i_enter_a_provider_named("Manch")
    and_i_click_on("Continue")
    then_i_see_list_of_placements_providers
    when_i_choose("Manchester 1")
    and_i_click_on("Continue")
    then_i_see_the_check_details_page_for_provider("Manchester 1")
    when_i_click_on("Back")
    then_i_see_list_of_placements_providers
    and_the_option_for_provider_has_been_pre_selected("Manchester 1")
    when_i_click_on("Back")
    then_i_see_the_search_input_pre_filled_with("Manch")
    and_i_click_on("Continue")
    then_i_see_list_of_placements_providers
    when_i_choose("Manchester 1")
    and_i_click_on("Continue")
    then_i_see_the_check_details_page_for_provider("Manchester 1")
  end

  scenario "Support user adds a partner provider, which is not onboarded on the placements service" do
    given_the_provider_is_not_onboarded_on_placements_service(provider)
    when_i_visit_the_add_partner_provider_page_for(school)
    and_i_enter_a_provider_named("Manch")
    and_i_click_on("Continue")
    then_i_see_list_of_placements_providers
    when_i_choose("Manchester 1")
    and_i_click_on("Continue")
    then_i_see_the_check_details_page_for_provider("Manchester 1")
    and_i_click_on("Add partner provider")
    then_i_return_to_partner_provider_index
    and_a_provider_is_listed(provider_name: "Manchester 1")
    and_i_see_success_message
    and_a_notification_email_is_not_sent_to(provider_user)
  end

  private

  def given_i_am_signed_in_as_a_support_user
    user = create(:placements_support_user, :colin)
    user_exists_in_dfe_sign_in(user:)
    visit sign_in_path
    click_on "Sign in using DfE Sign In"
  end

  def when_i_visit_the_add_partner_provider_page_for(school)
    visit new_add_partner_provider_placements_support_school_partner_providers_path(school)

    then_i_see_support_navigation_with_organisation_selected
  end

  def then_i_see_support_navigation_with_organisation_selected
    within(".app-primary-navigation__nav") do
      expect(page).to have_link "Organisations", current: "page"
      expect(page).to have_link "Support users", current: "false"
    end
  end

  def when_i_click_on(text)
    click_on text
  end
  alias_method :and_i_click_on, :when_i_click_on

  def and_i_enter_a_provider_named(provider_name)
    fill_in "Add a provider", with: provider_name
  end

  def then_i_see_list_of_placements_providers
    expect(page).to have_content("Manchester 1")
    expect(page).to have_content("Manchester 2")
    expect(page).not_to have_content("London")
    expect(page).not_to have_content("Claims")
  end

  def then_i_choose(selection_name)
    choose selection_name
  end
  alias_method :when_i_choose, :then_i_choose

  def then_i_see_the_check_details_page_for_provider(provider_name)
    expect(page).to have_css(".govuk-caption-l", text: "Partner provider details")
    expect(page).to have_content("Check your answers")
    org_name_row = page.all(".govuk-summary-list__row")[0]
    expect(org_name_row).to have_content(provider_name)
  end

  def then_i_return_to_partner_provider_index
    expect(page.find(".govuk-heading-l")).to have_content(school.name)
    expect(page.all(".govuk-heading-m")[1]).to have_content("Partner providers")
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

  def given_i_have_completed_the_form_to_select(provider:)
    params = {
      "partnership" => { provider_id: provider.id, provider_name: provider.name },
      school_id: school.id,
    }
    visit check_placements_support_school_partner_providers_path(params)
  end

  def then_i_see_the_search_input_pre_filled_with(provider_name)
    find_field "Add a provider", with: provider_name
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

  def and_the_option_for_provider_has_been_pre_selected(provider_name)
    expect(page).to have_checked_field(provider_name)
  end
end
