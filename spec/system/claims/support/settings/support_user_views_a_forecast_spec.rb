require "rails_helper"

RSpec.describe "Support user views a forecast for a claim window", service: :claims, type: :system do
  scenario do
    given_claims_exist_in_two_claim_windows
    and_i_am_signed_in
    when_i_navigate_to_the_settings_index_page
    then_i_see_the_forecast_link

    when_i_click_on_the_forecast_link
    then_i_see_the_claim_window_selection_page

    when_i_select_the_historic_claim_window
    and_i_click_on_view_forecast
    then_i_see_the_forecast_for_the_historic_claim_window
  end

  private

  def given_claims_exist_in_two_claim_windows
    @current_claim_window = create(:claim_window, :current)
    @historic_claim_window = create(:claim_window, :historic)

    @community_school = create(:claims_school, group: "Local authority maintained schools", type_of_establishment: "Community school")
    @academy = create(:claims_school, group: "Academies", type_of_establishment: "Academy converter")

    @community_claim = create(:claim, :submitted, school: @community_school, claim_window: @historic_claim_window)
    @academy_claim = create(:claim, :submitted, school: @academy, claim_window: @historic_claim_window)
    @current_claim = create(:claim, :submitted, school: @academy, claim_window: @current_claim_window)
    create(:claim, :draft, school: @academy, claim_window: @historic_claim_window)

    [@community_claim, @academy_claim, @current_claim].each do |claim|
      create(:mentor_training, claim:, hours_completed: 10)
    end
  end

  def and_i_am_signed_in
    sign_in_claims_support_user
  end

  def when_i_navigate_to_the_settings_index_page
    within(primary_navigation) do
      click_on "Settings"
    end
  end

  def then_i_see_the_forecast_link
    expect(page).to have_link("View claim forecast", href: "/support/forecast")
  end

  def when_i_click_on_the_forecast_link
    click_on "View claim forecast"
  end

  def then_i_see_the_claim_window_selection_page
    expect(page).to have_h1("Claim forecast", class: "govuk-heading-l")
    expect(page).to have_field("#{I18n.l(@current_claim_window.starts_on, format: :long)} to #{I18n.l(@current_claim_window.ends_on, format: :long)}")
    expect(page).to have_field("#{I18n.l(@historic_claim_window.starts_on, format: :long)} to #{I18n.l(@historic_claim_window.ends_on, format: :long)}")
  end

  def when_i_select_the_historic_claim_window
    choose "#{I18n.l(@historic_claim_window.starts_on, format: :long)} to #{I18n.l(@historic_claim_window.ends_on, format: :long)}"
  end

  def and_i_click_on_view_forecast
    click_on "View forecast"
  end

  def then_i_see_the_forecast_for_the_historic_claim_window
    expect(page).to have_checked_field("#{I18n.l(@historic_claim_window.starts_on, format: :long)} to #{I18n.l(@historic_claim_window.ends_on, format: :long)}")
    expect(page).to have_unchecked_field("#{I18n.l(@current_claim_window.starts_on, format: :long)} to #{I18n.l(@current_claim_window.ends_on, format: :long)}")
    expect(page).to have_h2("Academies")
    expect(page).to have_table_row({ "Type of establishment" => "Academy converter", "Amount" => @academy_claim.amount.format })
    expect(page).to have_h2("Local authority maintained schools")
    expect(page).to have_table_row({ "Type of establishment" => "Community school", "Amount" => @community_claim.amount.format })
    expect(page).to have_table_row({ "All groups" => "Total", "Amount" => (@academy_claim.amount + @community_claim.amount).format })
  end
end
