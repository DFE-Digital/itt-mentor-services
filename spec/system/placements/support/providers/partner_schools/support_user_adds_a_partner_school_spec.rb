require "rails_helper"

RSpec.describe "Placements / Support / Providers / Partner schools / Support user adds a partner school",
               service: :placements, type: :system do
  include ActiveJob::TestHelper

  let!(:school) { create(:placements_school, name: "School 1") }
  let!(:provider) { create(:placements_provider) }
  let!(:school_user) { create(:placements_user, schools: [school]) }

  around do |example|
    perform_enqueued_jobs { example.run }
  end

  before do
    given_i_am_signed_in_as_a_support_user
  end

  scenario "Support user adds a partner school", :js, retry: 3 do
    when_i_visit_the_partner_schools_page_for(provider)
    and_i_click_on("Add school")
    and_i_enter_a_school_named("School 1")
    then_i_see_a_dropdown_item_for("School 1")
    when_i_click_the_dropdown_item_for("School 1")
    and_i_click_on("Continue")
    then_i_see_the_check_details_page_for_school("School 1")
    when_i_click_on("Confirm and add school")
    then_i_return_to_partner_school_index_for(provider)
    and_a_school_is_listed(school_name: "School 1")
    and_i_see_success_message
    and_a_notification_email_is_sent_to(school_user)
  end

  scenario "Support user adds a partner school which already exists", :js, retry: 3 do
    given_a_partnership_exists_between(school, provider)
    when_i_visit_the_partner_schools_page_for(provider)
    and_i_click_on("Add school")
    and_i_enter_a_school_named("School 1")
    then_i_see_a_dropdown_item_for("School 1")
    when_i_click_the_dropdown_item_for("School 1")
    and_i_click_on("Continue")
    then_i_see_an_error("School 1 has already been added. Try another school")
  end

  scenario "Support user submits the search form without selecting a school", :js, retry: 3 do
    when_i_visit_the_add_partner_school_page_for(provider)
    and_i_click_on("Continue")
    then_i_see_an_error("Enter a school name, unique reference number (URN) or postcode")
  end

  scenario "Support user reconsiders selecting a school", :js, retry: 3 do
    when_i_visit_the_partner_schools_page_for(provider)
    and_i_click_on("Add school")
    and_i_enter_a_school_named("School 1")
    then_i_see_a_dropdown_item_for("School 1")
    when_i_click_the_dropdown_item_for("School 1")
    and_i_click_on("Continue")
    then_i_see_the_check_details_page_for_school("School 1")
    when_i_click_on("Back")
    then_i_see_the_search_input_pre_filled_with("School 1")
    and_i_click_on("Continue")
    then_i_see_the_check_details_page_for_school("School 1")
  end

  scenario "Support user adds a partner school, which is not onboarded on the placements service", :js, retry: 3 do
    given_the_school_is_not_onboarded_on_placements_service(school)
    when_i_visit_the_partner_schools_page_for(provider)
    and_i_click_on("Add school")
    and_i_enter_a_school_named("School 1")
    then_i_see_a_dropdown_item_for("School 1")
    when_i_click_the_dropdown_item_for("School 1")
    and_i_click_on("Continue")
    then_i_see_the_check_details_page_for_school("School 1")
    when_i_click_on("Confirm and add school")
    then_i_return_to_partner_school_index_for(provider)
    and_a_school_is_listed(school_name: "School 1")
    and_i_see_success_message
    and_a_notification_email_is_not_sent_to(school_user)
  end

  describe "when I use multiple tabs to add partner schools", :js do
    let(:school_2) { create(:school, :placements, name: "School 2") }
    let(:windows) do
      {
        open_new_window => { school: },
        open_new_window => { school: school_2 },
      }
    end

    it "persists the school details for each tab upon refresh" do
      windows.each do |window, details|
        within_window window do
          when_i_visit_the_partner_schools_page_for(provider)
          and_i_click_on("Add school")
          and_i_enter_a_school_named(details[:school].name)
          then_i_see_a_dropdown_item_for(details[:school].name)
          when_i_click_the_dropdown_item_for(details[:school].name)
          and_i_click_on("Continue")
          then_i_see_the_check_details_page_for_school(details[:school].name)
        end
      end

      # We need this test to be A -> B -> A -> B, so we can't combine the loops.
      # rubocop:disable Style/CombinableLoops
      windows.each do |window, details|
        within_window window do
          when_i_refresh_the_page
          then_the_school_details_have_not_changed(details[:school].name)
          when_i_click_on("Confirm and add school")
          then_i_return_to_partner_school_index_for(provider)
          and_a_school_is_listed(school_name: details[:school].name)
          and_i_see_success_message
        end
      end
      # rubocop:enable Style/CombinableLoops

      when_i_visit_the_partner_schools_page_for(provider)
      then_i_see_my_schools(windows.values)
    end
  end

  private

  def given_i_am_signed_in_as_a_support_user
    user = create(:placements_support_user, :colin)
    user_exists_in_dfe_sign_in(user:)
    visit sign_in_path
    click_on "Sign in using DfE Sign In"
  end

  def when_i_visit_the_partner_schools_page_for(provider)
    visit placements_provider_partner_schools_path(provider)

    then_i_see_support_navigation_with_organisation_selected
    partner_schools_is_selected_in_secondary_nav
  end

  def then_i_see_support_navigation_with_organisation_selected
    within(".govuk-header__navigation-list") do
      expect(page).to have_link "Organisations"
      expect(page).to have_link "Support users"
    end
  end

  def partner_schools_is_selected_in_secondary_nav
    within(".app-primary-navigation__list") do
      expect(page).to have_link "Organisation details", current: "false"
      expect(page).to have_link "Users", current: "false"
      expect(page).to have_link "Schools", current: "page"
    end
  end

  def when_i_click_on(text)
    click_on text
  end
  alias_method :and_i_click_on, :when_i_click_on

  def and_i_enter_a_school_named(school_name)
    fill_in "Add a school", with: school_name
  end

  def then_i_see_a_dropdown_item_for(school_name)
    expect(page).to have_css(".autocomplete__option", text: school_name)
  end

  def when_i_click_the_dropdown_item_for(school_name)
    page.find(".autocomplete__option", text: school_name).click
  end

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

  def when_i_visit_the_add_partner_school_page_for(provider)
    visit new_add_partner_school_placements_provider_partner_schools_path(provider)
  end

  def then_i_see_the_search_input_pre_filled_with(school_name)
    within(".autocomplete__wrapper") do
      find_field "Add a school", with: school_name
    end
  end

  def given_the_school_is_not_onboarded_on_placements_service(school)
    school.update!(placements_service: false)
  end

  def when_i_refresh_the_page
    visit current_path
  end

  def then_i_see_my_schools(schools)
    schools.each do |school|
      expect(page).to have_content(school[:school].name)
    end
  end

  alias_method :then_the_school_details_have_not_changed, :then_i_see_the_check_details_page_for_school
end
