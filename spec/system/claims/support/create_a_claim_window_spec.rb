require "rails_helper"

RSpec.describe "Create a claim window", freeze: "20 July 2024", service: :claims, type: :system do
  let(:support_user) { create(:claims_support_user) }

  before do
    user_exists_in_dfe_sign_in(user: support_user)
    given_i_sign_in
  end

  scenario "Support user creates a claim window" do
    when_i_visit_the_claim_windows_page
    and_i_click_on_the_add_claim_window_button
    then_i_see_the_form_to_create_a_claim_window

    when_i_click_continue
    then_i_see_a_form_error("Enter a window opening date")
    then_i_see_a_form_error("Enter a window closing date")

    when_i_fill_in_the_form(starts_on: Date.parse("21 July 2024"), ends_on: Date.parse("31 July 2024"))
    and_i_click_continue
    then_i_see_the_claim_window_details_check_page_with(start_date: "21 July 2024", end_date: "31 July 2024")

    when_i_click_on_change
    then_i_see_the_form_to_create_a_claim_window

    when_i_fill_in_the_form(starts_on: Date.parse("22 July 2024"), ends_on: Date.parse("31 July 2024"))
    and_i_click_continue
    then_i_see_the_claim_window_details_check_page_with(start_date: "22 July 2024", end_date: "31 July 2024")

    when_i_click_save
    then_i_see_the_claim_window_created_successfully_with(start_date: "22 July 2024", end_date: "31 July 2024")
  end

  private

  def given_i_sign_in
    visit sign_in_path
    click_on "Sign in using DfE Sign In"
  end

  def when_i_visit_the_claim_windows_page
    click_on "Settings"
    click_on "Claim windows"
  end

  def and_i_click_on_the_add_claim_window_button
    click_on "Add claim window"
  end

  def then_i_see_the_form_to_create_a_claim_window
    expect(page).to have_content("Add claim window")
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
  alias_method :when_i_click_continue, :and_i_click_continue

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
    expect(page).to have_content("Claim window created")
    expect(page).to have_content("#{start_date} to #{end_date}")
  end

  def when_i_click_on_change
    click_on "Change Window opens"
  end
end
