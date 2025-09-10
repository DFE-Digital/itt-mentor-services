require "rails_helper"

RSpec.describe "Support user views remind schools that have signed in to make claims when all schools have claimed", service: :claims, type: :system do
  scenario do
    given_i_am_signed_in
    and_schools_have_signed_in
    when_i_navigate_to_the_settings_index_page
    then_i_see_the_remind_schools_that_have_signed_in_link

    when_i_click_on_the_remind_schools_that_have_signed_in_link
    then_i_do_not_see_any_schools
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
    click_on "Remind schools to sign in"
  end

  def then_i_do_not_see_any_schools
    expect(page).to have_paragraph("All eligible schools have signed in for the current academic year, therefore no reminders can be sent.")
  end
end
