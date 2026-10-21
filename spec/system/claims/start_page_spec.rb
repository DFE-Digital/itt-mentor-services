require "rails_helper"

RSpec.describe "Start Page", freeze: "17 July 2024", service: :claims, type: :system do
  scenario "User visits the start page" do
    given_i_am_on_the_start_page
    then_i_can_see_the_start_page

    when_i_click_start_now
    then_i_land_on_the_sign_in_page
  end

  context "when there is no active claim window", freeze: "1 September 2024" do
    scenario "User visits the start page" do
      given_i_am_on_the_start_page
      then_i_see_the_claim_window_is_closed
    end
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
    within ".govuk-header__logo" do
      expect(page).to have_css("a.govuk-header__link.govuk-header__homepage-link")

      expect(page).to have_css(
        'img.govuk-header__logotype[alt="Department for Education"][src$="department-for-education_white.png"]',
        visible: :all,
      )
    end

    expect(page).to have_content(
      "Use this service to:\n"\
      "claim funding for eligible initial teacher training (ITT) mentor training "\
      "review mentor training claims selected for audit",
    )

    expect(page).to have_content(
      "Who can use this service\n"\
      "Schools and educational organisations\n"\
      "You can use this service if your organisation:\n"\
      "offers ITT placements with an accredited provider "\
      "has at least one team member who has started or is due to start ITT mentor training "\
      "is registered with Get Information About Schools (GIAS)",
    )

    expect(page).to have_content("This funding is not available for training early career framework (ECF) mentors. To claim for ECF mentors, you need a different service.")

    expect(page).to have_content(
      "Accredited ITT providers\n"\
      "You can use this service when claims involving your organisation are selected for audit.\n"\
      "You can:\n"\
      "review claims selected for audit "\
      "approve claims supported by your records "\
      "identify discrepancies where training records do not support all or part of a claim "\
      "submit audit responses through the service",
    )

    expect(page).to have_content(
      "When schools can submit a claim\n"\
      "For the school year starting September 2023:\n"\
      "schools can add ITT mentor training hours and submit a claim from May 2024 "\
      "registered users will receive email reminders about claim opening dates and deadlines",
    )

    expect(page).to have_content(
      "Before schools start a claim\n"\
      "You will need:\n"\
      "the name of your accredited ITT provider "\
      "your mentors’ teacher reference numbers (TRN) "\
      "your mentors’ dates of birth "\
      "completed training hours, which should be checked with your provider",
    )

    expect(page).to have_content(
      "Sign in\n"\
      "To access this service, you will be asked to sign in or create a Department for Education (DfE) Sign-in account. "\
      "DfE Sign-in is how schools, accredited providers and other education organisations access DfE online services.",
    )
  end

  def then_i_see_the_claim_window_is_closed
    expect(page).to have_content("The claim window for the current academic year has now closed. Schools cannot submit new claims at this time.")
    expect(page).to have_content("Accredited ITT providers can continue to access the service to complete audit activities where required.")
    expect(page).to have_content("Information about future claim windows will be published when available.")
    expect(page).not_to have_content("schools can add ITT mentor training hours and submit a claim from May 2024")
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
