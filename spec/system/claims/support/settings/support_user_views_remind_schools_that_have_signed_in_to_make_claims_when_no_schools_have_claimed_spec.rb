require "rails_helper"

RSpec.describe "Support user views remind schools that have signed in to make claims when all schools have claimed", service: :claims, type: :system do
  scenario do
    given_i_am_signed_in
    and_schools_have_signed_in
    when_i_navigate_to_the_settings_index_page
    then_i_see_the_remind_schools_that_have_signed_in_link

    when_i_click_on_the_remind_schools_that_have_signed_in_link
    then_i_see_information_about_schools_that_have_signed_in_and_not_claimed

    when_i_click_on_send_reminders
    then_i_see_the_reminders_sent_success_banner
  end

  private

  def given_i_am_signed_in
    sign_in_claims_support_user
  end

  def and_schools_have_signed_in
    @claim_window = create(:claim_window, :current)
    @eligibility = build(:eligibility, academic_year: @claim_window.academic_year)
    @school = build(:claims_school, eligibilities: [@eligibility])
    @user = create(:claims_user, last_signed_in_at: Time.zone.now, schools: [@school])
  end

  def when_i_navigate_to_the_settings_index_page
    within(primary_navigation) do
      click_on "Settings"
    end
  end

  def then_i_see_the_remind_schools_that_have_signed_in_link
    expect(page).to have_link("Remind schools that have signed in to make claims", href: "/support/claims_reminders/school_has_signed_in_but_not_claimed")
  end

  def when_i_click_on_the_remind_schools_that_have_signed_in_link
    click_on "Remind schools that have signed in to make claims"
  end

  def then_i_see_information_about_schools_that_have_signed_in_and_not_claimed
    expect(page).to have_title("Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Settings")
    expect(page).to have_h1("Remind schools that have signed in to make claims")
    expect(page).to have_paragraph("There is currently 1 school that has signed in but not made a claim for the current academic year.")
    expect(page).to have_paragraph("The deadline for submitting claims is #{I18n.l(@claim_window.ends_on, format: :long)}, the email that is sent will use this date.")
    expect(page).to have_link("Preview email (opens in new tab)", href: "/rails/mailers/claims/user_mailer/your_school_has_signed_in_but_not_claimed")
    expect(page).to have_warning_text("An email will be sent to all of the users for schools that have signed in but not made a claim for the current academic year. This action cannot be undone.")
    expect(page).to have_button("Send reminders")
  end

  def when_i_click_on_send_reminders
    click_on "Send reminders"
  end

  def then_i_see_the_reminders_sent_success_banner
    expect(page).to have_success_banner("Emails dispatched successfully", "An email has been sent to all of the users for schools that have not submitted claims for the current academic year.")
  end
end
