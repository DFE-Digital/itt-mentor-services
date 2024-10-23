require "rails_helper"

RSpec.describe "Placements / Schools / Partner providers / Remove a partner provider",
               service: :placements, type: :system do
  include ActiveJob::TestHelper

  around do |example|
    perform_enqueued_jobs { example.run }
  end

  let!(:school) { create(:placements_school) }
  let!(:provider) { create(:provider, :placements, name: "Provider 1") }
  let!(:another_provider) { create(:provider, name: "Another provider") }
  let(:partnership) { create(:placements_partnership, school:, provider:) }
  let(:another_partnership) do
    create(:placements_partnership, school:, provider: another_provider)
  end
  let!(:provider_user) { create(:placements_user, providers: [provider]) }

  before do
    partnership
    another_partnership
  end

  scenario "User removes a partner provider" do
    given_i_am_signed_in_as_a_placements_user(organisations: [school])
    when_i_view_the_partner_provider_show_page
    and_i_click_on("Delete provider")
    then_i_am_asked_to_confirm_partner_provider(provider)
    when_i_click_on("Cancel")
    then_i_return_to_partner_provider_page(provider)
    when_i_click_on("Delete provider")
    then_i_am_asked_to_confirm_partner_provider(provider)
    when_i_click_on("Delete provider")
    then_the_partner_provider_is_removed(provider)
    and_a_partner_provider_remains_called("Another provider")
    and_a_notification_email_is_sent_to(provider_user)
  end

  scenario "User removes a partner provider, which is not onboarded on the placements service" do
    given_the_provider_is_not_onboarded_on_placements_service(provider)
    given_i_am_signed_in_as_a_placements_user(organisations: [school])
    when_i_view_the_partner_provider_show_page
    and_i_click_on("Delete provider")
    then_i_am_asked_to_confirm_partner_provider(provider)
    when_i_click_on("Cancel")
    then_i_return_to_partner_provider_page(provider)
    when_i_click_on("Delete provider")
    then_i_am_asked_to_confirm_partner_provider(provider)
    when_i_click_on("Delete provider")
    then_the_partner_provider_is_removed(provider)
    and_a_partner_provider_remains_called("Another provider")
    and_a_notification_email_is_not_sent_to(provider_user)
  end

  private

  def when_i_view_the_partner_provider_show_page
    visit placements_school_partner_provider_path(school, provider)

    expect_partner_providers_to_be_selected_in_primary_navigation
  end

  def when_i_click_on(text)
    click_on text
  end
  alias_method :and_i_click_on, :when_i_click_on

  def then_i_am_asked_to_confirm_partner_provider(provider)
    expect_partner_providers_to_be_selected_in_primary_navigation

    expect(page).to have_title(
      "Are you sure you want to delete this provider? - #{provider.name} - Manage school placements",
    )
    expect(page).to have_content provider.name
    expect(page).to have_content "Are you sure you want to delete this provider?"
  end

  def then_i_return_to_partner_provider_page(provider)
    expect_partner_providers_to_be_selected_in_primary_navigation
    expect(page).to have_current_path placements_school_partner_provider_path(school, provider),
                                      ignore_query: true
  end

  def then_the_partner_provider_is_removed(provider)
    expect_partner_providers_to_be_selected_in_primary_navigation

    expect(school.partner_providers.find_by(id: provider.id)).to be_nil
    within(".govuk-notification-banner__content") do
      expect(page).to have_content "Provider deleted"
    end

    expect(page).to have_content provider.name, count: 1
  end

  def and_a_partner_provider_remains_called(provider_name)
    expect(page).to have_content(provider_name)
  end

  def partner_provider_notification(user)
    ActionMailer::Base.deliveries.find do |delivery|
      delivery.to.include?(user.email) &&
        delivery.subject == "A school has removed you"
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
      expect(page).to have_link "Providers", current: "page"
    end
  end

  def given_the_provider_is_not_onboarded_on_placements_service(provider)
    provider.update!(placements_service: false)
  end
end
