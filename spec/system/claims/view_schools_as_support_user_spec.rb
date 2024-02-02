require "rails_helper"

RSpec.describe "View schools as support user", type: :system do
  before do
    schools
  end

  scenario "I sign in as a support user to view schools and search by name" do
    given_i_am_signed_in_as_support_user
    then_i_see_all_schools_in_claims
    when_i_search_for_school("Manchester")
    then_i_see_only_the_manchester_school
    when_i_clear_search
    then_i_see_all_schools_in_claims
    when_i_search_for_school("Wrong search")
    then_i_see_no_results_page("Wrong search")
  end

  scenario "I sign in as a support user to view schools and search by postcode" do
    given_i_am_signed_in_as_support_user
    then_i_see_all_schools_in_claims
    when_i_search_for_school("M12")
    then_i_see_only_the_manchester_school
    when_i_clear_search
    then_i_see_all_schools_in_claims
    when_i_search_for_school("Wrong search")
    then_i_see_no_results_page("Wrong search")
  end

  private

  def schools
    @schools ||= [
      create(:school, :claims, name: "Manchester School", postcode: "M1234"),
      create(:school, :claims, name: "London School", postcode: "L5678"),
    ]
  end

  def given_i_am_signed_in_as_support_user
    user = create(:claims_support_user, :colin)
    user_exists_in_dfe_sign_in(user:)
    visit sign_in_path
    click_on "Sign in using DfE Sign In"
  end

  def then_i_see_all_schools_in_claims
    expect(page).to have_content("Organisations (#{@schools.count})")

    @schools.each do |school|
      expect(page).to have_content(school.name)
    end
  end

  def when_i_search_for_school(school_name)
    fill_in "Search by organisation name or postcode", with: school_name
    click_on "Search"
  end

  def then_i_see_only_the_manchester_school
    expect(page).to have_content("Manchester School")
    expect(page).not_to have_content("London School")
  end

  def when_i_clear_search
    click_on "Clear search"
  end

  def then_i_see_no_results_page(search_string)
    expect(page).to have_content("There are no results for '#{search_string}'")
  end
end
