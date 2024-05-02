require "rails_helper"

RSpec.describe "Placements / Schools / Partner providers / Remove a partner provider",
               type: :system,
               service: :placements do
  let!(:school) { create(:placements_school) }
  let!(:provider) { create(:placements_provider, name: "Provider 1") }
  let!(:another_provider) { create(:placements_provider, name: "Another provider") }
  let(:partnership) { create(:placements_partnership, school:, provider:) }
  let(:another_partnership) do
    create(:placements_partnership, school:, provider: another_provider)
  end

  before do
    partnership
    another_partnership
  end

  scenario "User removes a partner provider" do
    given_i_sign_in_as_anne
    when_i_view_the_partner_provider_show_page
    and_i_click_on("Remove partner provider")
    then_i_am_asked_to_confirm_partner_provider(provider)
    when_i_click_on("Cancel")
    then_i_return_to_partner_provider_page(provider)
    when_i_click_on("Remove partner provider")
    then_i_am_asked_to_confirm_partner_provider(provider)
    when_i_click_on("Remove partner provider")
    then_the_partner_provider_is_removed(provider)
    and_a_partner_provider_remains_called("Another provider")
  end

  private

  def given_i_sign_in_as_anne
    user = create(:placements_user, :anne)
    create(:user_membership, user:, organisation: school)
    user_exists_in_dfe_sign_in(user:)
    visit sign_in_path
    click_on "Start now"
  end

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
      "Are you sure you want to remove this partner provider? - #{provider.name} - Manage school placements",
    )
    expect(page).to have_content provider.name
    expect(page).to have_content "Are you sure you want to remove this partner provider?"
  end

  def then_i_return_to_partner_provider_page(provider)
    expect_partner_providers_to_be_selected_in_primary_navigation
    expect(page).to have_current_path placements_school_partner_provider_path(school, provider),
                                      ignore_query: true
  end

  def then_the_partner_provider_is_removed(provider)
    expect_partner_providers_to_be_selected_in_primary_navigation

    expect(school.partner_providers.find_by(id: provider.id)).to eq nil
    within(".govuk-notification-banner__content") do
      expect(page).to have_content "Partner provider removed"
    end

    expect(page).not_to have_content provider.name
  end

  def and_a_partner_provider_remains_called(provider_name)
    expect(page).to have_content(provider_name)
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
end
