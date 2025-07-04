require "rails_helper"

RSpec.describe "Support user adds a claim window which includes dates within an existing claim window",
               freeze: "04 July 2025",
               service: :claims,
               type: :system do
  scenario do
    given_a_claims_window_exists
    and_i_am_signed_in

    when_i_navigate_to_settings
    and_click_on_claims_windows
    then_i_see_the_claims_windows_index_page
    and_i_see_an_existing_claim_window

    when_i_click_on_add_claim_window
    then_i_see_the_claim_window_form

    when_i_enter_a_window_opens_date_before_the_existing_claim_window
    and_i_enter_a_window_closes_date_after_the_existing_claim_window
    and_i_select_the_academic_year_of_the_existing_claims_window
    and_i_click_on_continue
    then_i_see_a_validation_error_for_entering_dates_containing_existing_claims_windows
  end

  private

  def given_a_claims_window_exists
    @academic_year = AcademicYear.for_date("01/07/2025")
    @existing_claim_window = create(
      :claim_window,
      starts_on: Date.parse("01/07/2025"),
      ends_on: Date.parse("31/07/2025"),
      academic_year: @academic_year,
    )
  end

  def and_i_am_signed_in
    sign_in_claims_support_user
  end

  def when_i_navigate_to_settings
    within(primary_navigation) do
      click_on "Settings"
    end
  end

  def and_click_on_claims_windows
    click_on "Claim windows"
  end

  def then_i_see_the_claims_windows_index_page
    expect(page).to have_title("Claim windows - Claim funding for mentor training - GOV.UK")
    expect(page).to have_h1("Claim windows")
    expect(page).to have_current_path(claims_support_claim_windows_path)
    expect(page).to have_link(
      "Add claim window",
      href: new_claims_support_claim_window_path,
      class: "govuk-button",
    )
  end

  def and_i_see_an_existing_claim_window
    expect(page).to have_table_row(
      "Claim window" => "1 July 2025 to 31 July 2025",
      "Academic year" => "2024 to 2025",
      "Status" => "Current",
    )
  end

  def when_i_click_on_add_claim_window
    click_on "Add claim window"
  end

  def then_i_see_the_claim_window_form
    expect(page).to have_title("Window details - Claim funding for mentor training - GOV.UK")
    expect(page).to have_span_caption("Add claim window")
    expect(page).to have_h1("Window details")

    expect(page).to have_element(
      :legend,
      text: "Window opens",
      class: "govuk-fieldset__legend govuk-fieldset__legend--s",
    )
    within_fieldset "Window opens" do
      expect(page).to have_field("Day", type: :text)
      expect(page).to have_field("Month", type: :text)
      expect(page).to have_field("Year", type: :text)
    end

    expect(page).to have_element(
      :legend,
      text: "Window closes",
      class: "govuk-fieldset__legend govuk-fieldset__legend--s",
    )
    within_fieldset "Window closes" do
      expect(page).to have_field("Day", type: :text)
      expect(page).to have_field("Month", type: :text)
      expect(page).to have_field("Year", type: :text)
    end
  end

  def when_i_enter_a_window_opens_date_before_the_existing_claim_window
    within_fieldset "Window opens" do
      fill_in "Day", with: "1"
      fill_in "Month", with: "6"
      fill_in "Year", with: "2025"
    end
  end

  def and_i_enter_a_window_closes_date_after_the_existing_claim_window
    within_fieldset "Window closes" do
      fill_in "Day", with: "1"
      fill_in "Month", with: "8"
      fill_in "Year", with: "2025"
    end
  end

  def and_i_select_the_academic_year_of_the_existing_claims_window
    choose "2024 to 2025"
  end

  def and_i_click_on_continue
    click_on "Continue"
  end

  def then_i_see_a_validation_error_for_entering_dates_containing_existing_claims_windows
    expect(page).to have_validation_error("A claim window already exists within the selected dates")
  end
end
