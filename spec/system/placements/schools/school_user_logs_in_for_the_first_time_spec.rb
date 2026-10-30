require "rails_helper"

RSpec.describe "School user logs in for the first time", service: :placements, type: :system do
  scenario do
    given_my_school_is_onboarded
    and_i_am_signed_in
    then_i_see_the_placements_page

    when_i_click_on_the_users_tab
    then_i_see_the_users_page

    when_i_click_on_the_placements_tab
    then_i_see_the_placements_page
    and_my_school_has_not_been_updated
  end

  private

  def given_my_school_is_onboarded
    @school = create(:placements_school, expression_of_interest_completed: false, with_hosting_interest: false)
  end

  def and_i_am_signed_in
    sign_in_placements_user(organisations: [@school])
  end

  def then_i_see_the_placements_page
    expect(page).to have_title("Placements - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Placements")
    expect(page).to have_h1("Placements")
    expect(page).to have_current_path(placements_school_placements_path(@school))
    expect(page).to have_link("Add placement")
  end

  def when_i_click_on_the_users_tab
    within primary_navigation do
      click_on "Users"
    end
  end

  def then_i_see_the_users_page
    expect(page).to have_title("Users - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Users")
    expect(page).to have_h1("Users")
  end

  def when_i_click_on_the_placements_tab
    within primary_navigation do
      click_on "Placements"
    end
  end

  def and_my_school_has_not_been_updated
    expect(@school.reload.expression_of_interest_completed).to be(false)
    expect(@school.hosting_interests).to be_empty
  end
end
