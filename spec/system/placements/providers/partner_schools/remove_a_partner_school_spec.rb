require "rails_helper"

RSpec.describe "Placements / Providers / Partner schools / Remove a partner school",
               service: :placements, type: :system do
  include ActiveJob::TestHelper

  around do |example|
    perform_enqueued_jobs { example.run }
  end

  let!(:provider) { create(:placements_provider) }
  let!(:school) { create(:school, :placements, name: "School 1") }
  let!(:another_school) { create(:school, name: "Another school") }
  let(:partnership) { create(:placements_partnership, school:, provider:) }
  let(:another_partnership) do
    create(:placements_partnership, provider:, school: another_school)
  end

  before do
    partnership
    another_partnership
  end

  scenario "User removes a partner school" do
    given_i_am_signed_in_as_a_placements_user(organisations: [provider])
    when_i_view_the_partner_school_show_page
    and_i_click_on("Delete school")
    then_i_am_asked_to_confirm_partner_school(school)
    when_i_click_on("Cancel")
    then_i_return_to_partner_school_page(school)
    when_i_click_on("Delete school")
    then_i_am_asked_to_confirm_partner_school(school)
    when_i_click_on("Delete school")
    then_the_partner_school_is_removed(school)
    and_a_partner_provider_remains_called("Another school")
  end

  context "when the provider has placements associated with the partnership" do
    let(:english) { create(:subject, name: "English") }
    let(:maths) { create(:subject, name: "Mathematics") }
    let(:science) { create(:subject, name: "Science") }

    let(:placements_school) { school.becomes(Placements::School) }
    let(:english_placement) { create(:placement, school: placements_school, provider:, subject: english) }
    let(:maths_placement) { create(:placement, school: placements_school, provider:, subject: maths) }
    let(:science_placement) { create(:placement, school: placements_school, provider:, subject: science) }

    before do
      english_placement
      maths_placement
      science_placement
    end

    scenario "User removes a partner school, and see the placements listed" do
      given_i_am_signed_in_as_a_placements_user(organisations: [provider])
      when_i_view_the_partner_school_show_page
      and_i_click_on("Delete school")
      then_i_am_asked_to_confirm_partner_school(school)
      and_i_see_a_list_of_associated_placements_with_partner_school_and_provider
      when_i_click_on("Cancel")
      then_i_return_to_partner_school_page(school)
      when_i_click_on("Delete school")
      then_i_am_asked_to_confirm_partner_school(school)
      when_i_click_on("Delete school")
      then_the_partner_school_is_removed(school)
      and_a_partner_provider_remains_called("Another school")
    end
  end

  scenario "User removes a partner school, which is not onboarded on the placements service" do
    given_the_school_is_not_onboarded_on_placements_service(school)
    given_i_am_signed_in_as_a_placements_user(organisations: [provider])
    when_i_view_the_partner_school_show_page
    and_i_click_on("Delete school")
    then_i_am_asked_to_confirm_partner_school(school)
    when_i_click_on("Cancel")
    then_i_return_to_partner_school_page(school)
    when_i_click_on("Delete school")
    then_i_am_asked_to_confirm_partner_school(school)
    when_i_click_on("Delete school")
    then_the_partner_school_is_removed(school)
    and_a_partner_provider_remains_called("Another school")
  end

  private

  def when_i_view_the_partner_school_show_page
    visit placements_provider_partner_school_path(provider, school)

    expect_partner_schools_to_be_selected_in_primary_navigation
  end

  def when_i_click_on(text)
    click_on text
  end
  alias_method :and_i_click_on, :when_i_click_on

  def then_i_am_asked_to_confirm_partner_school(school)
    expect_partner_schools_to_be_selected_in_primary_navigation

    expect(page).to have_title(
      "Are you sure you want to delete this partner school? - #{school.name} - Manage school placements",
    )
    expect(page).to have_content school.name
    expect(page).to have_content "Are you sure you want to delete this school?"
  end

  def then_i_return_to_partner_school_page(school)
    expect_partner_schools_to_be_selected_in_primary_navigation
    expect(page).to have_current_path placements_provider_partner_school_path(provider, school),
                                      ignore_query: true
  end

  def then_the_partner_school_is_removed(school)
    expect_partner_schools_to_be_selected_in_primary_navigation

    expect(provider.partner_schools.find_by(id: school.id)).to be_nil
    within(".govuk-notification-banner__content") do
      expect(page).to have_content "School deleted"
    end

    expect(page).to have_content school.name, count: 1
  end

  def and_a_partner_provider_remains_called(provider_name)
    expect(page).to have_content(provider_name)
  end

  def expect_partner_schools_to_be_selected_in_primary_navigation
    nav = page.find(".app-primary-navigation__nav")

    within(nav) do
      expect(page).to have_link "Find", current: "false"
      expect(page).to have_link "My placements", current: "false"
      expect(page).to have_link "Schools", current: "page"
      expect(page).to have_link "Users", current: "false"
      expect(page).to have_link "Organisation details", current: "false"
    end
  end

  def given_the_school_is_not_onboarded_on_placements_service(school)
    school.update!(placements_service: false)
  end

  def and_i_see_a_list_of_associated_placements_with_partner_school_and_provider
    expect(page).to have_link("English (opens in new tab)")
    expect(page).to have_link("Mathematics (opens in new tab)")
    expect(page).to have_link("Science (opens in new tab)")
  end
end
