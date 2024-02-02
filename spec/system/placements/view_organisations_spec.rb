require "rails_helper"

RSpec.describe "View organisations", type: :system, service: :placements do
  scenario "I sign in as user Mary with multiple organistions" do
    given_the_placements_user("Mary")
    user_exists_in_dfe_sign_in(user: @user)
    and_user_has_multiple_organisations
    when_i_visit_sign_in_path
    when_i_click_sign_in
    i_am_redirected_to_organisation_index
    and_i_only_see_placement_schools
    when_i_click_on_school_name
    then_i_see_the_school_page(@multi_org_school)
    when_i_click_on_change_organisation
    i_am_redirected_to_organisation_index
    when_i_click_on_provider_name
    then_i_see_provider_page(@multi_org_provider)
    when_i_click_on_change_organisation
    i_am_redirected_to_organisation_index
  end

  scenario "I sign in as user Anne with one school" do
    given_the_placements_user("Anne")
    user_exists_in_dfe_sign_in(user: @user)
    and_user_has_one_school
    when_i_visit_sign_in_path
    when_i_click_sign_in
    then_i_see_the_one_school
  end

  scenario "I sign in as user Anne with one provider" do
    given_the_placements_user("Anne")
    user_exists_in_dfe_sign_in(user: @user)
    and_user_has_one_provider
    when_i_visit_sign_in_path
    when_i_click_sign_in
    then_i_see_the_one_provider
  end

  scenario "I cannot view a school unless it is a placements school" do
    given_the_placements_user("Anne")
    user_exists_in_dfe_sign_in(user: @user)
    and_user_has_a_school_without_a_service
    when_i_visit_sign_in_path
    when_i_click_sign_in
    then_i_am_redirected_to_404_when_i_visit_the_school
  end

  private

  def user(user_name)
    @user ||= create(:placements_user, user_name.downcase.to_sym)
  end

  def given_the_placements_user(user_name)
    user(user_name)
  end

  def and_user_has_a_school_without_a_service
    create(:membership, user: @user, organisation: create(:school, :placements))
    @school_without_placement = create(:school)
    create(:membership, user: @user, organisation: @school_without_placement)
  end

  def then_i_am_redirected_to_404_when_i_visit_the_school
    expect { visit placements_school_path(@school_without_placement) }.to raise_error(ActiveRecord::RecordNotFound)
  end

  def then_i_am_redirected_to_404
    expect(page).to have_content("ERROR")
  end

  def and_user_has_multiple_organisations
    @multi_org_school = create(:school, :placements, name: "Placements School")
    create(:membership, user: @user, organisation: @multi_org_school)

    @multi_org_provider = create(:placements_provider, name: "Provider 1")
    create(:membership, user: @user, organisation: @multi_org_provider)

    @claims_school = create(:school, :claims, name: "Claims School")
    create(:membership, user: @user, organisation: @claims_school)

    @no_service_school = create(:school, name: "No service school")
    create(:membership, user: @user, organisation: @no_service_school)
  end

  def when_i_click_on_school_name
    click_on "Placements School"
  end

  def then_i_see_the_school_page(school)
    expect(current_path).to eq placements_school_path(school)
    within(".app-primary-navigation__nav") do
      expect(page).to have_link "Organisation details", current: "page"
      expect(page).to have_link "Users", current: "false"
      expect(page).to have_link "Mentors", current: "false"
      expect(page).to have_link "Placements", current: "false"
    end

    within(".govuk-main-wrapper") do
      expect(page).to have_content school.name
      expect(page).to have_content "Organisation details"
      expect(page).to have_content "Additional details"
      expect(page).to have_content "Special educational needs and disabilities (SEND)"
      expect(page).to have_content "Ofsted"
      expect(page).to have_content "Contact details"
    end
  end

  def when_i_click_on_change_organisation
    click_on "Change organisation"
  end

  def when_i_click_on_provider_name
    click_on "Provider 1"
  end

  def then_i_see_provider_page(provider)
    expect(current_path).to eq placements_provider_path(provider)
    within(".govuk-main-wrapper") do
      expect(page).to have_content provider.name
      expect(page).to have_content "Organisation details"
      expect(page).to have_content "Contact details"
    end
  end

  def and_user_has_one_school
    @school = create(:school, :placements, name: "One School")
    create(:membership, user: @user, organisation: @school)
  end

  def and_user_has_one_provider
    @provider = create(:placements_provider, name: "One Provider")
    create(:membership, user: @user, organisation: @provider)
  end

  def then_i_see_the_one_school
    expect(page).to_not have_content "Change organisation"
    then_i_see_the_school_page(@school)
  end

  def then_i_see_the_one_provider
    expect(page).to_not have_content "Change organisation"
    then_i_see_provider_page(@provider)
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

    expect(page).to_not have_content "Claims School"
    expect(page).to_not have_content "No service school"
  end

  def i_am_redirected_to_organisation_index
    expect(page).to have_content("Organisations")
    expect(current_path).to eq placements_organisations_path
  end
end
