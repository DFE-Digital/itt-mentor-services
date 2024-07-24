require "rails_helper"

RSpec.describe "Start Page", service: :claims, type: :system do
  scenario "User visits the start page" do
    given_i_am_on_the_start_page
    then_i_can_see_the_start_page
    when_i_click_start_now
    then_i_land_on_the_sign_in_page
  end

  context "when signed in as a single-org user" do
    let(:single_org_user) do
      create(:claims_user) do |user|
        user.schools << create(:claims_school)
      end
    end

    scenario "User visits the start page" do
      given_i_am_signed_in_as(single_org_user)
      and_i_visit_the_start_page
      then_i_am_redirected_to_the_users_first_school_claims_page(single_org_user)
    end
  end

  context "when signed in as a multi-org user" do
    let(:multi_org_user) do
      create(:claims_user) do |user|
        user.schools << create(:claims_school)
        user.schools << create(:claims_school)
      end
    end

    scenario "User visits the start page" do
      given_i_am_signed_in_as(multi_org_user)
      and_i_visit_the_start_page
      then_i_am_redirected_to_the_users_school_list_page
    end
  end

  context "when signed in as a support user" do
    let(:support_user) { create(:claims_support_user) }

    scenario "User visits the start page" do
      given_i_am_signed_in_as(support_user)
      and_i_visit_the_start_page
      then_i_am_redirected_to_the_support_school_list_page
    end
  end

  private

  def given_i_am_signed_in_as(user)
    sign_in_as user
  end

  def given_i_am_on_the_start_page
    visit claims_root_path
  end
  alias_method :and_i_visit_the_start_page, :given_i_am_on_the_start_page

  def then_i_can_see_the_start_page
    within(".govuk-header") do
      expect(page).to have_content("Claim funding for mentor training")
    end

    expect(page).to have_content("Use this service to claim for mentors who supported, or intended to support, trainee teachers from September 2023 to July 2024.")
    expect(page).to have_content("Final closing date for claims: 11:59pm on Friday 19 July 2024")
    expect(page).to have_content("You must wait until May 2025 to claim for training that took place from April 2024 for the school year starting September 2025.")
    expect(page).to have_content(
      "Before you start\n"\
      "You’ll be asked for:\n"\
      "initial teacher training (ITT) provider name "\
      "your mentors’ teacher reference numbers (TRN) "\
      "your mentors’ dates of birth "\
      "hours of training each mentor completed",
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

  def then_i_am_redirected_to_the_users_first_school_claims_page(user)
    expect(page.current_url).to eq("http://claims.localhost/schools/#{user.schools.first.id}/claims")
  end

  def then_i_am_redirected_to_the_users_school_list_page
    expect(page.current_url).to eq("http://claims.localhost/schools")
  end

  def then_i_am_redirected_to_the_support_school_list_page
    expect(page.current_url).to eq("http://claims.localhost/support/schools")
  end
end
