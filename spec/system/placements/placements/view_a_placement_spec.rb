require "rails_helper"

RSpec.describe "Placements / Placements / View a placement",
               type: :system,
               service: :placements,
               js: true do
  let(:provider) { create(:placements_provider, name: "Provider") }
  let(:school) do
    create(
      :placements_school,
      name: "London Secondary School",
      phase: "Secondary",
      gender: "Mixed",
      minimum_age: 4,
      maximum_age: 11,
      religious_character: "Jewish",
      urban_or_rural: "(England/Wales) Urban city and town",
      admissions_policy: "Not applicable",
      percentage_free_school_meals: 11,
      rating: "Good",
      telephone: "01234567890",
      website: "www.a-london-example-school.com",
      email_address: "user@london-example-school.com",
      address1: "London Secondary School",
      address2: "London",
      address3: "City of London",
      postcode: "LN01 2LN",
    )
  end
  let!(:subject_1) { create(:subject, name: "Biology") }
  let!(:subject_2) { create(:subject, name: "Chemistry") }
  let!(:placement) do
    create(:placement, subjects:, school:)
  end

  before { given_i_sign_in_as_patricia }

  context "when the placement has one subject" do
    let(:subjects) { [subject_1] }

    scenario "User views a placement details" do
      when_i_visit_the_placement_show_page
      then_i_see_details_for_the_school
      and_i_see_the_subject_name("Biology")
      and_i_see_contact_details_for_the_school
    end
  end

  context "with multiple subjects" do
    let(:subjects) { [subject_1, subject_2] }

    scenario "User views a placement and multiple subject details" do
      when_i_visit_the_placement_show_page
      then_i_see_details_for_the_school
      and_i_see_the_subject_name("Biology and Chemistry")
      and_i_see_contact_details_for_the_school
    end
  end

  private

  def given_i_sign_in_as_patricia
    user = create(:placements_user, :patricia)
    create(:user_membership, user:, organisation: provider)
    user_exists_in_dfe_sign_in(user:)
    visit sign_in_path
    click_on "Sign in using DfE Sign In"
  end

  def when_i_visit_the_placement_show_page
    visit placements_placement_path(placement)

    expect_placements_to_be_selected_in_primary_navigation
  end

  def expect_placements_to_be_selected_in_primary_navigation
    nav = page.find(".app-primary-navigation__nav")

    within(nav) do
      expect(page).to have_link "Placements", current: "page"
      expect(page).to have_link "Partner schools", current: "false"
      expect(page).to have_link "Users", current: "false"
      expect(page).to have_link "Organisation details", current: "false"
    end
  end

  def then_i_see_details_for_the_school
    expect(page).to have_content("Placement - London Secondary School")
    expect(page).to have_content("Secondary")
    expect(page).to have_content("Mixed")
    expect(page).to have_content("4 to 11")
    expect(page).to have_content("Jewish")
    expect(page).to have_content("(England/Wales) Urban city and town")
    expect(page).to have_content("Not applicable")
    expect(page).to have_content("11")
    expect(page).to have_content("Good")
  end

  def and_i_see_contact_details_for_the_school
    expect(page).to have_content("Contact details")
    expect(page).to have_content("01234567890")
    expect(page).to have_content("www.a-london-example-school.com")
    expect(page).to have_content("user@london-example-school.com")
    expect(page).to have_content("London Secondary School\nLondon\nCity of London\nLN01 2LN")
  end

  def and_i_see_the_subject_name(subject_name)
    expect(page.find(".govuk-heading-l")).to have_content(subject_name)
  end
end
