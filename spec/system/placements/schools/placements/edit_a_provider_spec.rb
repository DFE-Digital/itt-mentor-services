require "rails_helper"

RSpec.describe "Placements / Schools / Placements / View a placement",
               type: :system, service: :placements do
  let!(:school) { create(:placements_school, name: "School 1", phase: "Primary") }
  let!(:placement) { create(:placement, school:) }
  let!(:provider_1) { create(:provider, :placements, name: "Provider 1") }
  let!(:provider_2) { create(:provider, :placements, name: "Provider 2") }

  before { given_i_sign_in_as_anne }

  context "when the school has no partner providers" do
    scenario "User is redirected to add a partner provider" do
      when_i_visit_the_placement_show_page
      then_i_should_see_the_provider_is_not_known_yet_in_the_placement_details(
        change_link: "Add a partner provider",
      )
      when_i_click_link(
        text: "Add a partner provider",
        href: placements_school_partner_providers_path(school),
      )
      then_i_am_redirected_to_add_a_partner_provider
    end
  end

  context "when the school has partner providers" do
    before do
      create(:placements_partnership, school:, provider: provider_1)
      create(:placements_partnership, school:, provider: provider_2)
    end

    context "with no provider" do
      scenario "User edits the provider" do
        when_i_visit_the_placement_show_page
        then_i_should_see_the_provider_is_not_known_yet_in_the_placement_details
        when_i_click_link(
          text: "Assign a provider",
          href: edit_provider_placements_school_placement_path(school, placement),
        )
        then_i_should_see_the_edit_provider_page
        when_i_select_provider_2
        and_i_click_on("Continue")
        then_i_should_see_the_provider_name_in_the_placement_details(
          provider_name: "Provider 2",
        )
        and_i_see_success_message("Provider updated")
      end

      scenario "User does not select a provider" do
        when_i_visit_the_placement_show_page
        then_i_should_see_the_provider_is_not_known_yet_in_the_placement_details
        when_i_click_link(
          text: "Assign a provider",
          href: edit_provider_placements_school_placement_path(school, placement),
        )
        then_i_should_see_the_edit_provider_page
        and_i_click_on("Continue")
        then_i_should_see_the_provider_is_not_known_yet_in_the_placement_details
      end

      scenario "User edits the provider and cancels" do
        when_i_visit_the_placement_show_page
        then_i_should_see_the_provider_is_not_known_yet_in_the_placement_details
        when_i_click_link(
          text: "Assign a provider",
          href: edit_provider_placements_school_placement_path(school, placement),
        )
        then_i_should_see_the_edit_provider_page
        when_i_select_provider_2
        and_i_click_on("Cancel")
        then_i_should_see_the_provider_is_not_known_yet_in_the_placement_details
      end

      scenario "User clicks on back" do
        when_i_visit_the_placement_show_page
        then_i_should_see_the_provider_is_not_known_yet_in_the_placement_details
        when_i_click_link(
          text: "Assign a provider",
          href: edit_provider_placements_school_placement_path(school, placement),
        )
        then_i_should_see_the_edit_provider_page
        and_i_click_on("Back")
        then_i_should_see_the_provider_is_not_known_yet_in_the_placement_details
      end
    end

    context "with a provider" do
      scenario "User edits the provider" do
        given_the_placement_has_a_provider(provider_1)
        when_i_visit_the_placement_show_page
        then_i_should_see_the_provider_name_in_the_placement_details(
          provider_name: "Provider 1",
        )
        when_i_click_link(
          text: "Change",
          href: edit_provider_placements_school_placement_path(school, placement),
        )
        then_i_should_see_the_edit_provider_page
        when_i_select_provider_2
        and_i_click_on("Continue")
        then_i_should_see_the_provider_name_in_the_placement_details(
          provider_name: "Provider 2",
        )
        and_i_see_success_message("Provider updated")
      end

      scenario "User does not select a provider" do
        given_the_placement_has_a_provider(provider_1)
        when_i_visit_the_placement_show_page
        then_i_should_see_the_provider_name_in_the_placement_details(
          provider_name: "Provider 1",
        )
        when_i_click_link(
          text: "Change",
          href: edit_provider_placements_school_placement_path(school, placement),
        )
        then_i_should_see_the_edit_provider_page
        when_i_choose_not_yet_known
        and_i_click_on("Continue")
        then_i_see_link(
          text: "Assign a provider",
          href: edit_provider_placements_school_placement_path(school, placement),
        )
        and_i_see_success_message("Provider updated")
      end
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

  def then_i_should_see_the_provider_is_not_known_yet_in_the_placement_details(
    change_link: "Assign a provider"
  )
    within(".govuk-summary-list") do
      expect(page).to have_content(change_link)
    end
  end

  def then_i_should_see_the_edit_provider_page
    expect(page).to have_content("Manage a placement")
  end

  def when_i_select_provider_2
    choose provider_2.name
  end

  def and_i_click_on(text)
    click_on text
  end
  alias_method :when_i_click_on, :and_i_click_on

  def when_i_click_link(text:, href:)
    click_link text, href:
  end

  def then_i_should_see_the_provider_name_in_the_placement_details(provider_name:, change_link: "Change")
    within(".govuk-summary-list") do
      expect(page).to have_content(provider_name)
      expect(page).to have_content(change_link)
    end
  end

  def given_the_placement_has_a_provider(provider)
    placement.update!(provider:)
  end

  def when_i_choose_not_yet_known
    choose "Not yet known"
  end

  def then_i_am_redirected_to_add_a_partner_provider
    expect(page).to have_current_path(
      placements_school_partner_providers_path(school), ignore_query: true
    )
  end

  def then_i_see_link(text:, href:)
    expect(page).to have_link(text, href:)
  end

  def and_i_see_success_message(message)
    within(".govuk-notification-banner") do
      expect(page).to have_content message
    end
  end
end
