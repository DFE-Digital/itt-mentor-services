require "rails_helper"

RSpec.describe "Support user views feature flags", :js, service: :placements, type: :system do
  scenario "Support user visits the emails page" do
    given_i_am_signed_in_as_a_placements_support_user
    then_i_see_the_organisations_page

    when_i_click_on_settings
    then_i_see_the_settings_page

    when_i_click_on_feature_flags
    then_i_see_the_feature_flags_page
  end

  private

  def given_i_am_signed_in_as_a_placements_support_user
    sign_in_placements_support_user
  end

  def then_i_see_the_organisations_page
    expect(page).to have_title("Organisations (0) - Manage school placements - GOV.UK")
    expect(page).to have_h1("Organisations (0)")
  end

  def when_i_click_on_settings
    within ".govuk-header" do
      click_on "Settings"
    end
  end

  def then_i_see_the_settings_page
    expect(page).to have_title("Manage school placements - GOV.UK")
    expect(page).to have_h1("Settings")
    expect(page).to have_link("Background jobs (opens in new tab)", href: "/good_job")
    expect(page).to have_link("Feature flags (opens in new tab)", href: "/flipper")
    expect(page).to have_link("Emails", href: "/support/mailers")
  end

  def when_i_click_on_feature_flags
    @feature_flag_window = window_opened_by do
      click_on "Feature flags"
    end
  end

  def then_i_see_the_feature_flags_page
    within_window @feature_flag_window do
      expect(page).to have_title("Features // Flipper")
      expect(page).to have_element(:h4, text: "But I've got a blank space baby...")
    end
  end
end
