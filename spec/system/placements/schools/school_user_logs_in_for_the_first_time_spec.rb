require "rails_helper"

RSpec.describe "School user logs in for the first time", service: :placements, type: :system do
  scenario do
    given_my_school_is_onboarded
    and_i_am_signed_in
    then_i_see_the_appetite_page

    when_i_click_on_the_users_tab
    then_i_see_the_users_page

    when_i_click_on_the_placements_tab
    then_i_see_the_appetite_page
  end

  private

  def given_my_school_is_onboarded
    @academic_year = Placements::AcademicYear.current.next
    @school = create(:placements_school, expression_of_interest_completed: false, with_school_contact: true)
  end

  def and_i_am_signed_in
    sign_in_placements_user(organisations: [@school])
  end

  def then_i_see_the_appetite_page
    expect(page).to have_title("Can your school offer placements for trainee teachers in this academic year (#{@academic_year.name})? - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Placements")
    expect(page).to have_element(:h1, text: "Can your school offer placements for trainee teachers in this academic year (#{@academic_year.name})?", class: "govuk-fieldset__heading")
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
end
