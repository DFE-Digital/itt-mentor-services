require "rails_helper"

RSpec.describe "Placements / Providers / Partner schools / Remove a partner school",
               type: :system,
               service: :placements do
  include ActiveJob::TestHelper

  around do |example|
    perform_enqueued_jobs { example.run }
  end

  let!(:provider) { create(:placements_provider) }
  let!(:school) { create(:school, :placements, name: "School 1") }
  let!(:another_school) { create(:school, name: "Another school") }
  let(:partnership) { create(:placements_partnership, school:, provider:) }
  let(:another_partnership) do
    create(:placements_partnership, provider:, school: another_school)
  end
  let!(:school_user) { create(:placements_user, schools: [school]) }

  before do
    partnership
    another_partnership
  end

  scenario "User removes a partner school" do
    given_i_sign_in_as_patricia
    when_i_view_the_partner_school_show_page
    and_i_click_on("Remove partner school")
    then_i_am_asked_to_confirm_partner_school(school)
    when_i_click_on("Cancel")
    then_i_return_to_partner_school_page(school)
    when_i_click_on("Remove partner school")
    then_i_am_asked_to_confirm_partner_school(school)
    when_i_click_on("Remove partner school")
    then_the_partner_school_is_removed(school)
    and_a_partner_provider_remains_called("Another school")
    and_a_notification_email_is_sent_to(school_user)
  end

  scenario "User removes a partner school, which is not onboarded on the placements service" do
    given_the_school_is_not_onboarded_on_placements_service(school)
    given_i_sign_in_as_patricia
    when_i_view_the_partner_school_show_page
    and_i_click_on("Remove partner school")
    then_i_am_asked_to_confirm_partner_school(school)
    when_i_click_on("Cancel")
    then_i_return_to_partner_school_page(school)
    when_i_click_on("Remove partner school")
    then_i_am_asked_to_confirm_partner_school(school)
    when_i_click_on("Remove partner school")
    then_the_partner_school_is_removed(school)
    and_a_partner_provider_remains_called("Another school")
    and_a_notification_email_is_not_sent_to(school_user)
  end

  private

  def given_i_sign_in_as_patricia
    user = create(:placements_user, :patricia)
    create(:user_membership, user:, organisation: provider)
    user_exists_in_dfe_sign_in(user:)
    visit sign_in_path
    click_on "Sign in using DfE Sign In"
  end

  def when_i_view_the_partner_school_show_page
    visit placements_provider_partner_school_path(provider, school)

    expect_partner_schools_to_be_selected_in_primary_navigation
  end

  def when_i_click_on(text)
    click_on text
  end
  alias_method :and_i_click_on, :when_i_click_on

  def then_i_am_asked_to_confirm_partner_school(school)
    expect_partner_schools_to_be_selected_in_primary_navigation

    expect(page).to have_title(
      "Are you sure you want to remove this partner school? - #{school.name} - Manage school placements",
    )
    expect(page).to have_content school.name
    expect(page).to have_content "Are you sure you want to remove this partner school?"
  end

  def then_i_return_to_partner_school_page(school)
    expect_partner_schools_to_be_selected_in_primary_navigation
    expect(page).to have_current_path placements_provider_partner_school_path(provider, school),
                                      ignore_query: true
  end

  def then_the_partner_school_is_removed(school)
    expect_partner_schools_to_be_selected_in_primary_navigation

    expect(provider.partner_schools.find_by(id: school.id)).to eq nil
    within(".govuk-notification-banner__content") do
      expect(page).to have_content "Partner school removed"
    end

    expect(page).not_to have_content school.name
  end

  def and_a_partner_provider_remains_called(provider_name)
    expect(page).to have_content(provider_name)
  end

  def partner_school_notification(user)
    ActionMailer::Base.deliveries.find do |delivery|
      delivery.to.include?(user.email) &&
        delivery.subject == "#{school.name} has been removed as a partner school"
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

  def expect_partner_schools_to_be_selected_in_primary_navigation
    nav = page.find(".app-primary-navigation__nav")

    within(nav) do
      expect(page).to have_link "Placements", current: "false"
      expect(page).to have_link "Partner schools", current: "page"
      expect(page).to have_link "Users", current: "false"
      expect(page).to have_link "Organisation details", current: "false"
    end
  end

  def given_the_school_is_not_onboarded_on_placements_service(school)
    school.update!(placements_service: false)
  end
end
