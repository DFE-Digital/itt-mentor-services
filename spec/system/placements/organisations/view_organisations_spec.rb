require "rails_helper"

RSpec.describe "View organisations", type: :system, service: :placements do
  let(:one_school) { create(:placements_school, name: "One School") }
  let(:one_provider) { create(:placements_provider, name: "One Provider") }
  let(:multi_org_school) { create(:placements_school, name: "Placements School") }
  let(:multi_org_provider) { create(:placements_provider, name: "Provider 1") }
  let(:claims_school) { create(:school, :claims, name: "Claims School") }
  let(:no_service_school) { create(:school, name: "No service school") }
  let(:school_without_placement) { create(:school) }

  scenario "I sign in as user Mary with multiple organistions" do
    user = given_the_placements_user("Mary")
    user_exists_in_dfe_sign_in(user:)
    and_user_has_multiple_organisations(user:)
    when_i_visit_sign_in_path
    when_i_click_sign_in
    i_am_redirected_to_organisation_index
    and_i_only_see_placement_schools
    when_i_click_on_school_name
    then_i_see_the_school_page(multi_org_school)
    when_i_click_on_change_organisation
    i_am_redirected_to_organisation_index
    when_i_click_on_provider_name
    then_i_see_provider_page(multi_org_provider)
    when_i_click_on_change_organisation
    i_am_redirected_to_organisation_index
  end

  scenario "I sign in as user Anne with one school" do
    user = given_the_placements_user("Anne")
    user_exists_in_dfe_sign_in(user:)
    and_user_has_one_school(user:)
    when_i_visit_sign_in_path
    when_i_click_sign_in
    then_i_see_the_one_school(one_school)
  end

  scenario "I sign in as user Anne with one provider" do
    user = given_the_placements_user("Anne")
    user_exists_in_dfe_sign_in(user:)
    and_user_has_one_provider(user:)
    when_i_visit_sign_in_path
    when_i_click_sign_in
    then_i_see_the_one_provider(one_provider)
  end

  scenario "I cannot view a school unless it is a placements school" do
    user = given_the_placements_user("Anne")
    user_exists_in_dfe_sign_in(user:)
    and_user_has_a_school_without_a_service(user:)
    when_i_visit_sign_in_path
    when_i_click_sign_in
    then_i_am_redirected_to_404_when_i_visit_the_school
  end

  private

  def user(user_name)
    create(:placements_user, user_name.downcase.to_sym)
  end

  def given_the_placements_user(user_name)
    user(user_name)
  end

  def and_user_has_a_school_without_a_service(user:)
    create(:user_membership, user:, organisation: create(:school, :placements))
    create(:user_membership, user:, organisation: school_without_placement)
  end

  def then_i_am_redirected_to_404_when_i_visit_the_school
    expect { visit placements_school_path(school_without_placement) }.to raise_error(ActiveRecord::RecordNotFound)
  end

  def then_i_am_redirected_to_404
    expect(page).to have_content("ERROR")
  end

  def and_user_has_multiple_organisations(user:)
    create(:user_membership, user:, organisation: multi_org_school)
    create(:user_membership, user:, organisation: multi_org_provider)
    create(:user_membership, user:, organisation: claims_school)
    create(:user_membership, user:, organisation: no_service_school)
  end

  def when_i_click_on_school_name
    click_on "Placements School"
  end

  def then_i_see_the_school_page(school)
    expect(page).to have_current_path placements_school_placements_path(school), ignore_query: true
    within(".app-primary-navigation__nav") do
      expect(page).to have_link "Placements", current: "page"
      expect(page).to have_link "Mentors", current: "false"
      expect(page).to have_link "Users", current: "false"
      expect(page).to have_link "Organisation details", current: "false"
    end

    within(".govuk-main-wrapper") do
      expect(page).to have_content school.name
      expect(page).to have_content "Placements"
    end
  end

  def when_i_click_on_change_organisation
    click_on "Change organisation"
  end

  def when_i_click_on_provider_name
    click_on "Provider 1"
  end

  def then_i_see_provider_page(provider)
    expect(page).to have_current_path placements_provider_path(provider), ignore_query: true
    within(".govuk-main-wrapper") do
      expect(page).to have_content provider.name
      expect(page).to have_content "Organisation details"
      expect(page).to have_content "Contact details"
    end
  end

  def and_user_has_one_school(user:)
    create(:user_membership, user:, organisation: one_school)
  end

  def and_user_has_one_provider(user:)
    create(:user_membership, user:, organisation: one_provider)
  end

  def then_i_see_the_one_school(school)
    expect(page).not_to have_content "Change organisation"
    then_i_see_the_school_page(school)
  end

  def then_i_see_the_one_provider(provider)
    expect(page).not_to have_content "Change organisation"
    then_i_see_provider_page(provider)
  end

  def when_i_visit_sign_in_path
    visit sign_in_path
  end

  def when_i_click_sign_in
    click_on "Sign in using DfE Sign In"
  end

  def and_i_only_see_placement_schools
    expect(page).to have_content "Placements School"
    expect(page).to have_content "Provider 1"

    expect(page).not_to have_content "Claims School"
    expect(page).not_to have_content "No service school"
  end

  def i_am_redirected_to_organisation_index
    expect(page).to have_content("Organisations")
    expect(page).to have_current_path placements_organisations_path, ignore_query: true
  end
end
