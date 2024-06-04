require "rails_helper"

RSpec.describe "Placements / Support / Schools / Partner providers / Support user removes a partner provider",
               type: :system,
               service: :placements do
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
    given_i_am_signed_in_as_a_support_user
  end

  scenario "Support user removes a partner provider" do
    when_i_view_the_partner_provider_show_page_for(school:, provider:)
    and_i_click_on("Remove partner provider")
    then_i_am_asked_to_confirm_partner_provider(provider)
    when_i_click_on("Cancel")
    then_i_return_to_partner_provider_page(provider)
    when_i_click_on("Remove partner provider")
    then_i_am_asked_to_confirm_partner_provider(provider)
    when_i_click_on("Remove partner provider")
    then_the_partner_provider_is_removed(provider)
    and_a_partner_provider_remains_called("Another provider")
    and_a_notification_email_is_sent_to(provider_user)
  end

  scenario "Support user removes a partner provider, which is not onboarded on the placements service" do
    given_the_provider_is_not_onboarded_on_placements_service(provider)
    when_i_view_the_partner_provider_show_page_for(school:, provider:)
    and_i_click_on("Remove partner provider")
    then_i_am_asked_to_confirm_partner_provider(provider)
    when_i_click_on("Cancel")
    then_i_return_to_partner_provider_page(provider)
    when_i_click_on("Remove partner provider")
    then_i_am_asked_to_confirm_partner_provider(provider)
    when_i_click_on("Remove partner provider")
    then_the_partner_provider_is_removed(provider)
    and_a_partner_provider_remains_called("Another provider")
    and_a_notification_email_is_not_sent_to(provider_user)
  end

  private

  def given_i_am_signed_in_as_a_support_user
    user = create(:placements_support_user, :colin)
    user_exists_in_dfe_sign_in(user:)
    visit sign_in_path
    click_on "Sign in using DfE Sign In"
  end

  def when_i_view_the_partner_provider_show_page_for(school:, provider:)
    visit placements_support_school_partner_provider_path(school, provider)

    then_i_see_support_navigation_with_organisation_selected
  end

  def when_i_click_on(text)
    click_on text
  end
  alias_method :and_i_click_on, :when_i_click_on

  def then_i_am_asked_to_confirm_partner_provider(provider)
    expect(page).to have_title(
      "Are you sure you want to remove this partner provider? - #{provider.name} " \
        "- #{school.name} - Manage school placements",
    )
    expect(page).to have_content provider.name
    expect(page).to have_content "Are you sure you want to remove this partner provider?"
  end

  def then_i_return_to_partner_provider_page(provider)
    expect(page).to have_current_path placements_support_school_partner_provider_path(school, provider),
                                      ignore_query: true
  end

  def then_the_partner_provider_is_removed(provider)
    partner_schools_is_selected_in_secondary_nav

    expect(school.partner_providers.find_by(id: provider.id)).to eq nil
    within(".govuk-notification-banner__content") do
      expect(page).to have_content "Partner provider removed"
    end

    expect(page).not_to have_content provider.name
  end

  def and_a_partner_provider_remains_called(provider_name)
    expect(page).to have_content(provider_name)
  end

  def partner_provider_notification(user)
    ActionMailer::Base.deliveries.find do |delivery|
      delivery.to.include?(user.email) &&
        delivery.subject == "A school has removed your organisation from its list of partner providers"
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

  def then_i_see_support_navigation_with_organisation_selected
    within(".app-primary-navigation__nav") do
      expect(page).to have_link "Organisations", current: "page"
      expect(page).to have_link "Support users", current: "false"
    end
  end

  def partner_schools_is_selected_in_secondary_nav
    within(".app-secondary-navigation__list") do
      expect(page).to have_link "Details", current: "false"
      expect(page).to have_link "Users", current: "false"
      expect(page).to have_link "Partner providers", current: "page"
      expect(page).to have_link "Mentors", current: "false"
      expect(page).to have_link "Placements", current: "false"
    end
  end

  def given_the_provider_is_not_onboarded_on_placements_service(provider)
    provider.update!(placements_service: false)
  end
end
