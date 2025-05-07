require "rails_helper"

RSpec.describe "Provider user can not view placements when flag disabled", service: :placements, type: :system do
  scenario do
    given_that_placements_exist
    and_the_provider_hide_find_placements_flag_is_disabled
    and_i_am_signed_in
    then_i_am_redirected_to_my_placements
    and_i_do_not_see_the_find_placements_tab
  end

  private

  def given_that_placements_exist
    academic_year = Placements::AcademicYear.current.next
    @provider = build(:placements_provider, name: "Aes Sedai Trust")
    @primary_school = build(:placements_school, phase: "Primary", name: "Springfield Elementary")
    @secondary_school = build(:placements_school, phase: "Secondary", name: "Shelbyville High School")
    @all_through_school = build(:placements_school, phase: "All-through", name: "Ogdenville Observatoire")

    @primary_subject = build(:subject, name: "Primary with mathematics", subject_area: "primary")
    @springfield_primary_placement = create(:placement, school: @primary_school, subject: @primary_subject, provider: @provider, academic_year:)

    @secondary_subject = build(:subject, name: "Music", subject_area: "secondary")
    @shelbyville_secondary_placement = create(:placement, school: @secondary_school, subject: @secondary_subject, provider: @provider, academic_year:)
    @ogdenville_secondary_placement = create(:placement, school: @all_through_school, subject: @secondary_subject, provider: @provider, academic_year:)
  end

  def and_i_am_signed_in
    sign_in_placements_user(organisations: [@provider])
  end

  def and_the_provider_hide_find_placements_flag_is_disabled
    Flipper.add(:provider_hide_find_placements)
    Flipper.enable(:provider_hide_find_placements)
  end

  def then_i_am_redirected_to_my_placements
    expect(page).to have_title("My placements - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("My placements")
    expect(page).to have_current_path placements_provider_placements_path(@provider), ignore_query: true
  end

  def and_i_do_not_see_the_find_placements_tab
    within(".app-primary-navigation__nav") do
      expect(page).not_to have_link "Find"
      expect(page).to have_link "My placements", current: "page"
      expect(page).to have_link "Schools", current: "false"
      expect(page).to have_link "Users", current: "false"
      expect(page).to have_link "Organisation details", current: "false"
    end
  end
end
