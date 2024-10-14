require "rails_helper"

RSpec.describe "Start Page", freeze: "17 July 2024", service: :claims, type: :system do
  before do
    allow(MarkdownDocument).to receive(:from_directory).and_return([
      MarkdownDocument.from_file(file_fixture("service_update.md")),
    ])
  end

  scenario "User visits the start page" do
    given_i_am_on_the_start_page
    then_i_can_see_the_start_page
    then_i_see_a_link_to_all_service_updates

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

    expect(page).to have_content("Use this service to make a claim for the time spent becoming an initial teacher training (ITT) mentor.")

    expect(page).to have_content(
      "Who can use this service\n"\
      "You can use this service if you are a school or education organisation that:\n"\
      "offers ITT placements with an accredited provider "\
      "has at least one team member who has started or is due to start their ITT mentor training "\
      "is registered with Get information about schools (GIAS)",
    )

    expect(page).to have_content("This funding is not available for training early career framework (ECF) mentors. To claim for ECF mentors, you need a different service.")

    expect(page).to have_content(
      "When to submit a claim\n"\
      "For the school year starting September 2024:\n"\
      "you can add your ITT mentor training hours and submit a claim from May 2025 "\
      "when you are registered in the service, we will email you reminders of claim opening dates and deadlines",\
    )

    expect(page).to have_content(
      "Before you start\n"\
      "You will be asked for:\n"\
      "the name of your accredited ITT provider "\
      "your mentors’ teacher reference numbers (TRN) "\
      "your mentors’ dates of birth "\
      "completed training hours - you should check these with your provider",
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

  def then_i_see_a_link_to_all_service_updates
    expect(page).to have_link("Service Update", href: "/service-updates#service-update")
    expect(page).to have_link("View all news and updates", href: "/service-updates")
  end
end
