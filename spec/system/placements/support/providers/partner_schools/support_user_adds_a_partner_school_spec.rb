require "rails_helper"

RSpec.describe "Placements / Support / Providers / Partner schools / Support user adds a partner school",
               type: :system,
               service: :placements do
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

  scenario "Support user adds a partner school", js: true, retry: 3 do
    when_i_visit_the_partner_schools_page_for(provider)
    and_i_click_on("Add partner school")
    and_i_enter_a_school_named("School 1")
    then_i_see_a_dropdown_item_for("School 1")
    when_i_click_the_dropdown_item_for("School 1")
    and_i_click_on("Continue")
    then_i_see_the_check_details_page_for_school("School 1")
    when_i_click_on("Add partner school")
    then_i_return_to_partner_school_index_for(provider)
    and_a_school_is_listed(school_name: "School 1")
    and_i_see_success_message
    and_a_notification_email_is_sent_to(school_user)
  end

  scenario "Support user adds a partner school which already exists", js: true, retry: 3 do
    given_a_partnership_exists_between(school, provider)
    when_i_visit_the_partner_schools_page_for(provider)
    and_i_click_on("Add partner school")
    and_i_enter_a_school_named("School 1")
    then_i_see_a_dropdown_item_for("School 1")
    when_i_click_the_dropdown_item_for("School 1")
    and_i_click_on("Continue")
    then_i_see_an_error("School 1 has already been added. Try another school")
  end

  scenario "Support user submits the search form without selecting a school", js: true, retry: 3 do
    when_i_visit_the_add_partner_school_page_for(provider)
    and_i_click_on("Continue")
    then_i_see_an_error("Enter a school name, URN or postcode")
  end

  scenario "Support user reconsiders selecting a school", js: true, retry: 3 do
    given_i_have_completed_the_form_to_select(school:)
    when_i_click_on("Back")
    then_i_see_the_search_input_pre_filled_with("School 1")
    and_i_click_on("Continue")
    then_i_see_the_check_details_page_for_school("School 1")
  end

  scenario "Support user adds a partner school, which is not onboarded on the placements service",
           js: true, retry: 3 do
    given_the_school_is_not_onboarded_on_placements_service(school)
    when_i_visit_the_partner_schools_page_for(provider)
    and_i_click_on("Add partner school")
    and_i_enter_a_school_named("School 1")
    then_i_see_a_dropdown_item_for("School 1")
    when_i_click_the_dropdown_item_for("School 1")
    and_i_click_on("Continue")
    then_i_see_the_check_details_page_for_school("School 1")
    when_i_click_on("Add partner school")
    then_i_return_to_partner_school_index_for(provider)
    and_a_school_is_listed(school_name: "School 1")
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

  def when_i_visit_the_partner_schools_page_for(provider)
    visit placements_support_provider_partner_schools_path(provider)

    then_i_see_support_navigation_with_organisation_selected
    partner_schools_is_selected_in_secondary_nav
  end

  def then_i_see_support_navigation_with_organisation_selected
    within(".app-primary-navigation__nav") do
      expect(page).to have_link "Organisations", current: "page"
      expect(page).to have_link "Users", current: "false"
    end
  end

  def partner_schools_is_selected_in_secondary_nav
    within(".app-secondary-navigation__list") do
      expect(page).to have_link "Details", current: "false"
      expect(page).to have_link "Users", current: "false"
      expect(page).to have_link "Providers", current: "false"
      expect(page).to have_link "Placements", current: "false"
      expect(page).to have_link "Partner schools", current: "page"
    end
  end

  def when_i_click_on(text)
    click_on text
  end
  alias_method :and_i_click_on, :when_i_click_on

  def and_i_enter_a_school_named(school_name)
    fill_in "partnership-school-id-field", with: school_name
  end

  def then_i_see_a_dropdown_item_for(school_name)
    expect(page).to have_css(".autocomplete__option", text: school_name)
  end

  def when_i_click_the_dropdown_item_for(school_name)
    page.find(".autocomplete__option", text: school_name).click
  end

  def then_i_see_the_check_details_page_for_school(school_name)
    expect(page).to have_css(".govuk-caption-l", text: "Add partner school")
    expect(page).to have_content("Check your answers")
    org_name_row = page.all(".govuk-summary-list__row")[0]
    expect(org_name_row).to have_content(school_name)
  end

  def then_i_return_to_partner_school_index_for(provider)
    expect(page.find(".govuk-heading-l")).to have_content(provider.name)
    expect(page.all(".govuk-heading-m")[1]).to have_content("Partner schools")
  end

  def and_a_school_is_listed(school_name:)
    expect(page).to have_content(school_name)
  end

  def and_i_see_success_message
    expect(page).to have_content "Partner school added"
  end

  def partner_school_notification(user)
    ActionMailer::Base.deliveries.find do |delivery|
      delivery.to.include?(user.email) &&
        delivery.subject == "An ITT provider has added your organisation to its list of partner schools"
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
    visit new_placements_support_provider_partner_school_path(provider)
  end

  def given_i_have_completed_the_form_to_select(school:)
    params = {
      "partnership" => { school_id: school.id, school_name: school.name },
      provider_id: provider.id,
    }
    visit check_placements_support_provider_partner_schools_path(params)
  end

  def then_i_see_the_search_input_pre_filled_with(school_name)
    within(".autocomplete__wrapper") do
      expect(page.find("#partnership-school-id-field").value).to eq(school_name)
    end
  end

  def given_the_school_is_not_onboarded_on_placements_service(school)
    school.update!(placements_service: false)
  end
end