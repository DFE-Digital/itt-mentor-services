require "rails_helper"

RSpec.describe "Sign in Page", type: :system, service: :claims do
  scenario "User visits the start page" do
    given_i_am_on_the_start_page
    then_i_can_see_the_start_page
    when_i_click_start_now
    then_i_land_on_the_sign_in_page
  end

  private

  def given_i_am_on_the_start_page
    visit claims_root_path
  end

  def then_i_can_see_the_start_page
    within(".govuk-header") do
      expect(page).to have_content("Claim funding for mentor training")
    end

    expect(page).to have_content(
      "You can claim funding for mentors who supported trainee teachers from "\
       "September 2023 to July 2024.",
    )
    expect(page).to have_content(
      "Training that took place for April 2024 for the school year starting "\
      "September 2024 can only be claimed for from May 2025.",
    )
    expect(page).to have_content(
      "Before you start\n"\
      "You’ll be asked for:\n"\
      "initial teacher training (ITT) provider details "\
      "your mentors’ teacher reference numbers (TRN) "\
      "hours of training each mentor completed",
    )
    expect(page).to have_content(
      "Get an account to claim funding for mentor training\n"\
      "Ask a colleague within your organisation to add you if you do not have an account.\n"\
      "If your organisation has not been set up to claim funding for mentor training, "\
      "send an email to becomingateacher@digital.education.gov.uk.",
    )
    expect(page).to have_content("Related content")
    expect(page).to have_link(
      "Guidance for providers on initial teacher training (ITT)",
      href: "https://www.gov.uk/government/collections/initial-teacher-training",
    )
    expect(page).to have_link(
      "Find out what a teacher reference number (TRN) is and how to find or request a TRN",
      href: "https://www.gov.uk/guidance/teacher-reference-number-trn",
    )
  end

  def when_i_click_start_now
    click_on("Start now")
  end

  def then_i_land_on_the_sign_in_page
    expect(page.current_url).to eq("http://claims.localhost/sign-in")
  end
end
