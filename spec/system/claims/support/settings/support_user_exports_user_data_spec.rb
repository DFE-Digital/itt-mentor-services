require "rails_helper"

RSpec.describe "Support user exports user data", service: :claims, type: :system do
  scenario do
    given_a_support_user_is_signed_in

    when_i_visit_the_settings_page
    and_i_click_on_export_users
    then_i_see_the_claim_window_step

    when_i_click_continue_without_selecting_an_option
    then_i_see_the_select_claim_window_to_include_error

    when_i_select_specific_claim_window
    and_i_click_continue
    then_i_see_the_specific_claim_window_step

    when_i_click_continue_without_selecting_an_option
    then_i_see_the_select_a_claim_window_error

    when_i_select_a_claim_window
    and_i_click_continue
    then_i_see_the_activity_level_step

    when_i_click_continue_without_selecting_an_option
    then_i_see_the_select_a_users_to_include_error

    when_i_select_all_users
    and_i_click_continue
    then_i_see_the_check_your_answers_page_with_persisted_answers

    when_i_click_back
    then_i_see_the_activity_level_step_with_persisted_answer

    when_i_click_back
    then_i_see_the_specific_claim_window_step_with_persisted_answer

    when_i_click_back
    then_i_see_the_claim_window_step_with_persisted_answer

    when_i_click_continue_until_check_answers_again
    and_i_click_download_csv
    then_i_receive_a_csv_download
  end

  private

  def given_a_support_user_is_signed_in
    @support_user = create(:claims_support_user)
    @claim_window = create(:claim_window, :current)
    @claim_window_name = @claim_window.decorate.name
    sign_in_as(@support_user)
  end

  def when_i_visit_the_settings_page
    visit claims_support_settings_path
  end

  def and_i_click_on_export_users
    click_on "Export users"
  end
  alias_method :when_i_click_on_export_users, :and_i_click_on_export_users

  def then_i_see_the_claim_window_step
    expect(page).to have_title("Which claim windows do you want to include? - Claim funding for mentor training - GOV.UK")
    expect(page).to have_field("All claim windows", type: :radio)
    expect(page).to have_field("A specific claim window", type: :radio)
  end

  def when_i_click_cancel
    click_on "Cancel"
  end

  def then_i_see_the_settings_page
    expect(page).to have_link("Export users", href: "/support/export_users")
  end

  def when_i_select_specific_claim_window
    choose "A specific claim window"
  end

  def and_i_click_continue
    click_on "Continue"
  end

  def then_i_see_the_specific_claim_window_step
    expect(page).to have_title("Choose a claim window - Claim funding for mentor training - GOV.UK")
    expect(page).to have_field(@claim_window_name, type: :radio)
  end

  def when_i_select_a_claim_window
    choose @claim_window_name
  end

  def then_i_see_the_activity_level_step
    expect(page).to have_title("Which users do you want to include? - Claim funding for mentor training - GOV.UK")
    expect(page).to have_field("All users", type: :radio)
    expect(page).to have_field("Active users", type: :radio)
  end

  def when_i_select_all_users
    choose "All users"
  end

  def then_i_see_the_check_your_answers_page_with_persisted_answers
    expect(page).to have_title("Check your answers before downloading - Claim funding for mentor training - GOV.UK")
    expect(page).to have_summary_list_row("Claim window", @claim_window_name)
    expect(page).to have_summary_list_row("Activity level", "All users")
  end

  def when_i_click_back
    click_link "Back"
  end

  def then_i_see_the_activity_level_step_with_persisted_answer
    expect(page).to have_title("Which users do you want to include? - Claim funding for mentor training - GOV.UK")
    expect(page).to have_checked_field("All users")
  end

  def then_i_see_the_specific_claim_window_step_with_persisted_answer
    expect(page).to have_title("Choose a claim window - Claim funding for mentor training - GOV.UK")
    expect(page).to have_checked_field(@claim_window_name)
  end

  def then_i_see_the_claim_window_step_with_persisted_answer
    expect(page).to have_title("Which claim windows do you want to include? - Claim funding for mentor training - GOV.UK")
    expect(page).to have_checked_field("A specific claim window")
  end

  def when_i_click_continue_until_check_answers_again
    3.times { and_i_click_continue }
    expect(page).to have_title("Check your answers before downloading - Claim funding for mentor training - GOV.UK")
  end

  def and_i_click_download_csv
    click_button "Download CSV"
  end

  def then_i_receive_a_csv_download
    expect(page.response_headers["Content-Disposition"]).to include('attachment; filename="exported_users_')
    expect(page.response_headers["Content-Type"]).to include("text/csv")

    csv = CSV.parse(page.body, headers: true)
    expect(csv.headers).to eq(%w[school_urn school_name user_first_name user_last_name email_address])
  end

  def when_i_click_continue_without_selecting_an_option
    click_on "Continue"
  end

  def then_i_see_the_select_claim_window_error
    expect(page).to have_css(".govuk-error-summary")
    expect(page).to have_css(".govuk-error-summary__list li", text: "Select which claim windows to include")
  end

  def then_i_see_the_select_claim_window_to_include_error
    expect(page).to have_css(".govuk-error-summary")
    expect(page).to have_css(".govuk-error-summary__list li", text: "Select which claim windows to include")
  end

  def then_i_see_the_select_a_claim_window_error
    expect(page).to have_css(".govuk-error-summary")
    expect(page).to have_css(".govuk-error-summary__list li", text: "Select a claim window")
  end

  def then_i_see_the_select_a_users_to_include_error
    expect(page).to have_css(".govuk-error-summary")
    expect(page).to have_css(".govuk-error-summary__list li", text: "Select which users to include")
  end
end
