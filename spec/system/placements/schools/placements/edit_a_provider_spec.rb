require "rails_helper"

RSpec.describe "Placements / Schools / Placements / View a placement",
               type: :system, service: :placements do
  let!(:school) { create(:placements_school, name: "School 1", phase: "Primary") }
  let!(:placement) { create(:placement, school:) }
  let!(:provider_1) { create(:provider, name: "Provider 1") }
  let!(:provider_2) { create(:provider, name: "Provider 2") }

  before do
    given_i_sign_in_as_anne
  end

  context "with no provider", js: true do
    scenario "User edits the provider" do
      when_i_visit_the_placement_show_page
      then_i_should_see_the_provider_is_not_known_yet_in_the_placement_details
      when_i_click_on_change
      then_i_should_see_the_edit_provider_page
      when_i_select_provider_2
      and_i_click_on("Continue")
      then_i_should_see_the_provider_name_in_the_placement_details("Provider 2")
    end

    scenario "User does not select a provider" do
      when_i_visit_the_placement_show_page
      then_i_should_see_the_provider_is_not_known_yet_in_the_placement_details
      when_i_click_on_change
      then_i_should_see_the_edit_provider_page
      and_i_click_on("Continue")
      then_i_should_see_the_provider_is_not_known_yet_in_the_placement_details
    end

    scenario "User edits the provider and cancels" do
      when_i_visit_the_placement_show_page
      then_i_should_see_the_provider_is_not_known_yet_in_the_placement_details
      when_i_click_on_change
      then_i_should_see_the_edit_provider_page
      when_i_select_provider_2
      and_i_click_on("Cancel")
      then_i_should_see_the_provider_is_not_known_yet_in_the_placement_details
    end

    scenario "User clicks on back" do
      when_i_visit_the_placement_show_page
      then_i_should_see_the_provider_is_not_known_yet_in_the_placement_details
      when_i_click_on_change
      then_i_should_see_the_edit_provider_page
      and_i_click_on("Back")
      then_i_should_see_the_provider_is_not_known_yet_in_the_placement_details
    end
  end

  context "with a provider" do
    scenario "User edits the provider", js: true do
      given_the_placement_has_a_provider(provider_1)
      when_i_visit_the_placement_show_page
      then_i_should_see_the_provider_name_in_the_placement_details("Provider 1")
      when_i_click_on_change
      then_i_should_see_the_edit_provider_page
      when_i_select_provider_2
      and_i_click_on("Continue")
      then_i_should_see_the_provider_name_in_the_placement_details("Provider 2")
    end

    scenario "User does not select a provider", js: true do
      given_the_placement_has_a_provider(provider_1)
      when_i_visit_the_placement_show_page
      then_i_should_see_the_provider_name_in_the_placement_details("Provider 1")
      when_i_click_on_change
      then_i_should_see_the_edit_provider_page
      when_i_remove_the_provider_from_the_search_box
      and_i_click_on("Continue")
      then_i_should_see_the_provider_name_in_the_placement_details("Not known yet")
    end
  end

  private

  def and_there_is_an_existing_user_for(user_name)
    user = create(:placements_user, user_name.downcase.to_sym)
    user_exists_in_dfe_sign_in(user:)
    create(:user_membership, user:, organisation: school)
  end

  def and_i_visit_the_sign_in_path
    visit sign_in_path
  end

  def and_i_click_sign_in
    click_on "Sign in using DfE Sign In"
  end

  def when_i_visit_the_placement_show_page
    visit placements_school_placement_path(school, placement)
  end

  def given_i_sign_in_as_anne
    and_there_is_an_existing_user_for("Anne")
    and_i_visit_the_sign_in_path
    and_i_click_sign_in
  end

  def then_i_should_see_the_provider_is_not_known_yet_in_the_placement_details
    within(".govuk-summary-list") do
      expect(page).to have_content("Not known yet")
      expect(page).to have_content("Change")
    end
  end

  def then_i_should_see_the_edit_provider_page
    expect(page).to have_content("Edit placement")
  end

  def when_i_select_provider_2
    fill_in "Provider - Edit placement", with: provider_2.name
    find("#placement-provider-id-field__option--0").click
  end

  def and_i_click_on(text)
    click_on text
  end

  def when_i_click_on_change
    click_link "Change", href: edit_provider_placements_school_placement_path(school, placement)
  end

  def then_i_should_see_the_provider_name_in_the_placement_details(provider_name)
    within(".govuk-summary-list") do
      expect(page).to have_content(provider_name)
      expect(page).to have_content("Change")
    end
  end

  def given_the_placement_has_a_provider(provider)
    placement.update!(provider:)
  end

  def when_i_remove_the_provider_from_the_search_box
    fill_in "Provider - Edit placement", with: ""
  end

  alias_method :when_i_click_on, :and_i_click_on
end