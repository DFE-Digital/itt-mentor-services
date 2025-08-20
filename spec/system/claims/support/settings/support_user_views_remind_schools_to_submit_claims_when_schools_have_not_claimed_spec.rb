require "rails_helper"

RSpec.describe "Support user views remind schools to submit claims when schools have not claimed", service: :claims, type: :system do
  scenario do
    given_i_am_signed_in
    and_schools_have_not_claimed
    when_i_navigate_to_the_settings_index_page
    then_i_see_the_remind_schools_to_submit_claims_link

    when_i_click_on_the_remind_schools_to_submit_claims_link
    then_i_see_information_about_schools_that_have_not_claimed
  end

  private

  def given_i_am_signed_in
    sign_in_claims_support_user
  end

  def and_schools_have_not_claimed
    @academic_year = AcademicYear.current
    @claim_window = build(:claim_window, :current, academic_year: @academic_year)
    @eligibility = build(:eligibility, claim_window: @claim_window)
    @school = create(:claims_school, eligibilities: [@eligibility])
  end

  def when_i_navigate_to_the_settings_index_page
    within(primary_navigation) do
      click_on "Settings"
    end
  end

  def then_i_see_the_remind_schools_to_submit_claims_link
    expect(page).to have_link("Remind schools to submit claims", href: "/support/claims_reminders/schools_not_submitted_claims")
  end

  def when_i_click_on_the_remind_schools_to_submit_claims_link
    click_on "Remind schools to submit claims"
  end

  def then_i_see_information_about_schools_that_have_not_claimed
    expect(page).to have_title("Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Settings")
    expect(page).to have_h1("Remind schools to submit claims")
    expect(page).to have_paragraph("There is currently 1 school that has not submitted claims for the current claim window.")
    expect(page).to have_paragraph("The deadline for submitting claims is #{I18n.l(@claim_window.ends_on, format: :long)}, the email that is sent will use this date.")
    expect(page).to have_link("Preview email (opens in new tab)", href: "/rails/mailers/claims/user_mailer/claims_have_not_been_submitted")
    expect(page).to have_warning_text("An email will be sent to all of the users for schools that have not submitted claims for the current claim window. This action cannot be undone.")
    expect(page).to have_button("Send reminders")
  end

  def when_i_click_on_send_reminders
    click_on "Send reminders"
  end

  def then_i_see_the_reminders_sent_success_banner
    expect(page).to have_success_banner("An email has been sent to all of the users for schools that have not submitted claims for the current claim window.")
  end
end
