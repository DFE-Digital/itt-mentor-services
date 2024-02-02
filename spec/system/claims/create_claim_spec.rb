require "rails_helper"

RSpec.describe "Create claim", type: :system, js: true, service: :claims do
  let!(:school) { create(:claims_school) }
  let!(:anne) do
    create(
      :claims_user,
      :anne,
      memberships: [create(:membership, organisation: school)],
    )
  end
  let!(:provider) { create(:provider) }
  let!(:mentor) { create(:mentor, school:) }

  before do
    user_exists_in_dfe_sign_in(user: anne)
    given_i_sign_in
  end

  scenario "Anne creates a draft claim" do
    when_i_visit_claim_index_page
    and_i_click("Add claim")
    then_i_see_my_claim_check_list(
      providers_status: "Not started",
      mentors_status: "Not started",
    )
    and_i_click("ITT providers")
    and_i_input_a_provider(provider.name.first(3))
    then_i_see_a_dropdown_item_for(provider.name)
    when_i_click_the_dropdown_item_for(provider.name)
    and_i_click_continue
    then_i_see_my_claim_check_list(
      providers_status: "Completed",
      mentors_status: "Not started",
    )

    and_i_click("General mentors")
    and_i_input_a_mentor(mentor.first_name.first(3))
    then_i_see_a_dropdown_item_for(mentor.first_name)
    when_i_click_the_dropdown_item_for(mentor.first_name)
    and_i_click_continue
    then_i_see_my_claim_check_list(
      providers_status: "Completed",
      mentors_status: "Completed",
    )
  end

  scenario "Anne creates does not input a provider" do
    when_i_visit_claim_index_page
    and_i_click("Add claim")
    then_i_see_my_claim_check_list(
      providers_status: "Not started",
      mentors_status: "Not started",
    )
    and_i_click("ITT providers")
    and_i_click_continue
    then_i_see_an_error_message("Enter a provider name")
  end

  scenario "Anne does not input an existing provider" do
    when_i_visit_claim_index_page
    and_i_click("Add claim")
    then_i_see_my_claim_check_list(
      providers_status: "Not started",
      mentors_status: "Not started",
    )
    and_i_click("ITT providers")
    and_i_input_a_provider("non existent")
    and_i_click_continue
    then_i_see_an_error_message("Enter a provider name")
  end

  scenario "Anne does not input a mentor" do
    when_i_visit_claim_index_page
    and_i_click("Add claim")
    then_i_see_my_claim_check_list(
      providers_status: "Not started",
      mentors_status: "Not started",
    )
    and_i_click("General mentor")
    and_i_click_continue
    then_i_see_an_error_message("Enter a mentor's name")
  end

  scenario "Anne does not input an existing mentor" do
    when_i_visit_claim_index_page
    and_i_click("Add claim")
    then_i_see_my_claim_check_list(
      providers_status: "Not started",
      mentors_status: "Not started",
    )
    and_i_click("General mentor")

    and_i_input_a_mentor("non existent")
    and_i_click_continue
    then_i_see_an_error_message("Enter a mentor's name")
  end

  private

  def given_i_sign_in
    visit sign_in_path
    click_on "Sign in using DfE Sign In"
  end

  def when_i_visit_claim_index_page
    click_on("Claims")
  end

  def and_i_click(button)
    click_on(button)
  end

  def then_i_see_my_claim_check_list(providers_status:, mentors_status:)
    expect(page).to have_content("Claim general mentor training funding")
    expect(page).to have_content("1. ITT providers")
    within(".providers-task-list") do
      expect(page).to have_content("ITT providers")
      expect(page).to have_content(providers_status)
    end

    expect(page).to have_content("2. General mentors")
    within(".mentors-task-list") do
      expect(page).to have_content("General mentors")
      expect(page).to have_content(mentors_status)
    end
  end

  def and_i_input_a_provider(string)
    fill_in("claim-mentor-trainings-attributes-0-provider-id-field", with: string)
  end

  def and_i_input_a_mentor(string)
    fill_in("claim-mentor-trainings-attributes-0-mentor-id-field", with: string)
  end

  def then_i_see_a_dropdown_item_for(item_name)
    expect(page).to have_css(".autocomplete__option", text: item_name)
  end

  def and_i_click_continue
    click_on("Continue")
  end

  def when_i_click_the_dropdown_item_for(provider_name)
    page.find(".autocomplete__option", text: provider_name).click
  end

  def then_i_see_an_error_message(message)
    expect(page).to have_content(message)
  end
end
