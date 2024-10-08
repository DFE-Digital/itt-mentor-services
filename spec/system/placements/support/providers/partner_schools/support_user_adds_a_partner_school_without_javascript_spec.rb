require "rails_helper"

RSpec.describe "Placements / Support / Providers / Partner schools / Support user adds a partner school without JavaScript",
               service: :placements, type: :system do
  include ActiveJob::TestHelper

  around do |example|
    perform_enqueued_jobs { example.run }
  end

  let!(:school) { create(:school, :placements, name: "Manchester 1") }
  let!(:provider) { create(:placements_provider) }
  let!(:school_user) { create(:placements_user, schools: [school]) }

  before do
    create(:school, name: "Manchester 2")
    create(:school, :placements, name: "London")
    create(:school, :claims, name: "Claims")

    given_i_am_signed_in_as_a_support_user
  end

  scenario "Support user adds a partner school" do
    when_i_visit_the_add_partner_school_page_for(provider)
    and_i_enter_a_school_named("Manch")
    and_i_click_on("Continue")
    then_i_see_list_of_placements_schools
    when_i_choose("Manchester 1")
    and_i_click_on("Continue")
    then_i_see_the_check_details_page_for_school("Manchester 1")
    and_i_click_on("Confirm and add school")
    then_i_return_to_partner_school_index_for(provider)
    and_a_school_is_listed(school_name: "Manchester 1")
    and_i_see_success_message
    and_a_notification_email_is_sent_to(school_user)
  end

  scenario "Support user adds a partner school which already exists" do
    given_a_partnership_exists_between(school, provider)
    when_i_visit_the_add_partner_school_page_for(provider)
    and_i_enter_a_school_named("Manch")
    and_i_click_on("Continue")
    then_i_see_list_of_placements_schools
    when_i_choose("Manchester 1")
    and_i_click_on("Continue")
    then_i_see_an_error("Manchester 1 has already been added. Try another school")
  end

  scenario "Support user submits the search form without selecting a school" do
    when_i_visit_the_add_partner_school_page_for(provider)
    and_i_click_on("Continue")
    then_i_see_an_error("Enter a school name, unique reference number (URN) or postcode")
  end

  scenario "Support user submits the options form without selecting a school" do
    when_i_visit_the_add_partner_school_page_for(provider)
    and_i_enter_a_school_named("Manch")
    and_i_click_on("Continue")
    then_i_see_list_of_placements_schools
    and_i_click_on("Continue")
    then_i_see_an_error("Select a school")
  end

  scenario "Support user reconsiders selecting a school" do
    when_i_visit_the_add_partner_school_page_for(provider)
    and_i_enter_a_school_named("Manch")
    and_i_click_on("Continue")
    then_i_see_list_of_placements_schools
    when_i_choose("Manchester 1")
    and_i_click_on("Continue")
    then_i_see_the_check_details_page_for_school("Manchester 1")
    when_i_click_on("Back")
    then_i_see_list_of_placements_schools
    and_the_option_for_school_has_been_pre_selected("Manchester 1")
    when_i_click_on("Back")
    then_i_see_the_search_input_pre_filled_with("Manch")
    and_i_click_on("Continue")
    then_i_see_list_of_placements_schools
    when_i_choose("Manchester 1")
    and_i_click_on("Continue")
    then_i_see_the_check_details_page_for_school("Manchester 1")
  end

  scenario "Support user adds a partner school, which is not onboarded on the placements service" do
    given_the_school_is_not_onboarded_on_placements_service(school)
    when_i_visit_the_add_partner_school_page_for(provider)
    and_i_enter_a_school_named("Manch")
    and_i_click_on("Continue")
    then_i_see_list_of_placements_schools
    when_i_choose("Manchester 1")
    and_i_click_on("Continue")
    then_i_see_the_check_details_page_for_school("Manchester 1")
    and_i_click_on("Confirm and add school")
    then_i_return_to_partner_school_index_for(provider)
    and_a_school_is_listed(school_name: "Manchester 1")
    and_i_see_success_message
    and_a_notification_email_is_not_sent_to(school_user)
  end

  private

  def given_i_am_signed_in_as_a_support_user
    user = create(:placements_support_user, :colin)
    user_exists_in_dfe_sign_in(user:)
    visit sign_in_path
    click_on "Sign in using DfE Sign In"
  end

  def when_i_visit_the_add_partner_school_page_for(provider)
    visit new_add_partner_school_placements_provider_partner_schools_path(provider)

    then_i_see_support_navigation_with_organisation_selected
  end

  def then_i_see_support_navigation_with_organisation_selected
    within(".govuk-header__navigation-list") do
      expect(page).to have_link "Organisations"
      expect(page).to have_link "Support users"
    end
  end

  def when_i_click_on(text)
    click_on text
  end
  alias_method :and_i_click_on, :when_i_click_on

  def and_i_enter_a_school_named(school_name)
    fill_in "Add a school", with: school_name
  end

  def then_i_see_list_of_placements_schools
    expect(page).to have_content("Manchester 1")
    expect(page).to have_content("Manchester 2")
    expect(page).not_to have_content("London")
    expect(page).not_to have_content("Claims")
  end

  def then_i_choose(selection_name)
    choose selection_name
  end
  alias_method :when_i_choose, :then_i_choose

  def then_i_see_the_check_details_page_for_school(school_name)
    expect(page).to have_content("Confirm school details")
    org_name_row = page.all(".govuk-summary-list__row")[0]
    expect(org_name_row).to have_content(school_name)
  end

  def then_i_return_to_partner_school_index_for(_provider)
    expect(page.find(".govuk-heading-l")).to have_content("Schools you work with")
  end

  def and_a_school_is_listed(school_name:)
    expect(page).to have_content(school_name)
  end

  def and_i_see_success_message
    expect(page).to have_content "School added"
  end

  def partner_school_notification(user)
    ActionMailer::Base.deliveries.find do |delivery|
      delivery.to.include?(user.email) &&
        delivery.subject == "A teacher training provider has added your organisation to its list of partner schools"
    end
  end

  def and_a_notification_email_is_sent_to(user)
    email = partner_school_notification(user)

    expect(email).not_to be_nil
  end

  def and_a_notification_email_is_not_sent_to(user)
    email = partner_school_notification(user)

    expect(email).to be_nil
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

  def then_i_see_the_search_input_pre_filled_with(school_name)
    find_field "Add a school", with: school_name
  end

  def given_the_school_is_not_onboarded_on_placements_service(school)
    school.update!(placements_service: false)
  end

  def and_the_option_for_school_has_been_pre_selected(school_name)
    expect(page).to have_checked_field(school_name)
  end
end
