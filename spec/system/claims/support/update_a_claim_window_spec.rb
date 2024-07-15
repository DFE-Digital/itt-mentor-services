require "rails_helper"

RSpec.describe "Update a claim window", freeze: "17 July 2024", service: :claims, type: :system do
  let(:support_user) { create(:claims_support_user) }

  before do
    user_exists_in_dfe_sign_in(user: support_user)
    given_i_sign_in
  end

  scenario "Support user updates a claim window" do
    _past_window = given_there_is_a_claim_window(starts_on: "1 January 2024", ends_on: "15 January 2024")
    _current_window = given_there_is_a_claim_window(starts_on: "1 July 2024", ends_on: "31 July 2024")
    _upcoming_window = given_there_is_a_claim_window(starts_on: "1 August 2024", ends_on: "15 August 2024")

    when_i_visit_the_claim_windows_page
    then_i_see("1 January 2024 to 15 January 2024")
    and_i_see("1 July 2024 to 31 July 2024")
    and_i_see("1 August 2024 to 15 August 2024")

    when_i_click_on("1 August 2024 to 15 August 2024")
    and_i_click_on("Change Window opens")
    then_i_see_the_form_to_update_a_claim_window

    when_i_fill_in_the_form(starts_on: Date.parse("15 July 2024"), ends_on: Date.parse("31 July 2024"))
    and_i_click_on("Continue")
    then_i_see_a_form_error("Select a date that is not within an existing claim window")

    when_i_fill_in_the_form(starts_on: Date.parse("16 July 2024"), ends_on: Date.parse("12 August 2024"))
    and_i_click_on("Continue")
    then_i_see_a_form_error("Select a date that is not within an existing claim window")

    when_i_fill_in_the_form(starts_on: Date.parse("25 August 2024"), ends_on: Date.parse("31 August 2024"))
    and_i_click_on("Continue")
    then_i_see_the_claim_window_details_check_page_with(start_date: "25 August 2024", end_date: "31 August 2024")

    when_i_click_on("Change Window opens")
    then_i_see_the_form_to_update_a_claim_window

    when_i_fill_in_the_form(starts_on: Date.parse("15 August 2024"), ends_on: Date.parse("31 August 2024"))
    and_i_click_on("Continue")
    then_i_see_the_claim_window_details_check_page_with(start_date: "15 August 2024", end_date: "31 August 2024")

    when_i_click_on("Save claim window")
    then_i_see_the_claim_window_created_successfully_with(start_date: "15 August 2024", end_date: "31 August 2024")
  end

  private

  def given_i_sign_in
    visit sign_in_path
    click_on "Sign in using DfE Sign In"
  end

  def given_there_is_a_claim_window(starts_on:, ends_on:)
    Claims::ClaimWindow::Build.call(claim_window_params: { starts_on:, ends_on: }).save!(validate: false)
  end

  def when_i_visit_the_claim_windows_page
    click_on "Settings"
    click_on "Claim windows"
  end

  def then_i_see(content)
    expect(page).to have_content(content)
  end
  alias_method :and_i_see, :then_i_see

  alias_method :and_i_click_on, :click_on
  alias_method :when_i_click_on, :click_on

  def then_i_see_the_form_to_update_a_claim_window
    expect(page).to have_content("Change claim window")
    expect(page).to have_css("legend", text: "Window opens")
    expect(page).to have_css("legend", text: "Window closes")
  end

  def when_i_fill_in_the_form(starts_on:, ends_on:)
    fill_in "claims_claim_window[starts_on(3i)]", with: starts_on.day
    fill_in "claims_claim_window[starts_on(2i)]", with: starts_on.month
    fill_in "claims_claim_window[starts_on(1i)]", with: starts_on.year

    fill_in "claims_claim_window[ends_on(3i)]", with: ends_on.day
    fill_in "claims_claim_window[ends_on(2i)]", with: ends_on.month
    fill_in "claims_claim_window[ends_on(1i)]", with: ends_on.year
  end

  def and_i_click_continue
    click_on "Continue"
  end

  def then_i_see_a_form_error(message)
    expect(page).to have_content(message)
  end

  def then_i_see_the_claim_window_details_check_page_with(start_date:, end_date:)
    expect(page).to have_content("Check your answers")
    expect(page).to have_content("Window opens#{start_date}")
    expect(page).to have_content("Window closes#{end_date}")
  end

  def when_i_click_save
    click_on "Save claim window"
  end

  def then_i_see_the_claim_window_created_successfully_with(start_date:, end_date:)
    expect(page).to have_content("Claim window updated")
    expect(page).to have_content("#{start_date} to #{end_date}")
  end

  def when_i_click_on_change
    click_on "Change Window opens"
  end
end
