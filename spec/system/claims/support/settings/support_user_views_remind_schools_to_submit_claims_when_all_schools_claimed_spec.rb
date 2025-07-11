require "rails_helper"

RSpec.describe "Support user views remind schools to submit claims when all schools claimed", service: :claims, type: :system do
  scenario do
    given_i_am_signed_in_and_a_claim_window_is_open
    when_i_navigate_to_the_settings_index_page
    then_i_see_the_remind_schools_to_submit_claims_link

    when_i_click_on_the_remind_schools_to_submit_claims_link
    then_i_do_not_see_any_schools
  end

  private

  def given_i_am_signed_in_and_a_claim_window_is_open
    @claim_window = create(:claim_window, :current)
    sign_in_claims_support_user
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

  def then_i_do_not_see_any_schools
    expect(page).to have_paragraph("All eligible schools have submitted claims for the current claim window, therefore no reminders can be sent.")
  end
end
