require "rails_helper"

RSpec.describe "Provider user attempts to navigate to placements", service: :placements, type: :system do
  scenario "When the show provider placements feature flag is disabled" do
    given_that_placements_exist
    given_there_is_a_show_providers_feature_flag
    when_the_show_provider_placements_feature_flag_is_disabled
    and_i_am_signed_in

    then_i_see_the_find_schools_page
    and_there_is_no_placements_tab_in_the_navigation_window

    when_i_attempt_to_navigate_to_the_placements_page
    then_i_am_prevented_from_doing_so
  end

  private

  def given_that_placements_exist
    @provider = build(:placements_provider, name: "Aes Sedai Trust")
    @primary_school = build(:placements_school, phase: "Primary", name: "Springfield Elementary")
    @autumn_term = build(:placements_term, :autumn)

    @primary_maths_subject = build(:subject, name: "Primary with mathematics", subject_area: "primary")
    _primary_maths_placement = create(:placement, school: @primary_school, subject: @primary_maths_subject,
                                                  terms: [@autumn_term])

    @primary_english_subject = build(:subject, name: "Primary with english", subject_area: "primary")
    _primary_english_placement = create(:placement, school: @primary_school, subject: @primary_english_subject,
                                                    terms: [@autumn_term])
  end

  def and_i_am_signed_in
    sign_in_placements_user(organisations: [@provider])
  end

  def given_there_is_a_show_providers_feature_flag
    Flipper.add(:show_provider_placements)
  end

  def when_the_show_provider_placements_feature_flag_is_enabled
    Flipper.enable(:show_provider_placements)
  end

  def when_the_show_provider_placements_feature_flag_is_disabled
    Flipper.disable(:show_provider_placements)
  end

  def then_i_see_the_find_schools_page
    expect(page).to have_title("Find schools hosting placements - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Find")
    expect(page).to have_h1("Find schools hosting placements")
    expect(page).to have_h2("Filter")
  end

  def and_there_is_no_placements_tab_in_the_navigation_window
    within primary_navigation do
      expect(page).not_to have_link "Placements", current: "false"
      expect(page).to have_link "Find", current: "page"
      expect(page).to have_link "Schools", current: "false"
      expect(page).to have_link "Users", current: "false"
      expect(page).to have_link "Organisation details", current: "false"
    end
  end

  def when_i_attempt_to_navigate_to_the_placements_page
    visit placements_provider_placements_path(@provider)
  end

  def then_i_am_prevented_from_doing_so
    expect(page).to have_title("Manage school placements")
    expect(page).to have_important_banner("You cannot perform this action")
  end
end
