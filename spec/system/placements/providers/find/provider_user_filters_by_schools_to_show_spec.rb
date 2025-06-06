require "rails_helper"

RSpec.describe "Provider user filters schools by schools I work with", service: :placements, type: :system do
  scenario do
    given_that_schools_exist
    and_i_am_signed_in

    when_i_navigate_to_the_find_schools_page
    then_i_see_the_find_schools_page
    and_i_see_the_school_springfield_elementary
    and_i_see_the_school_brixton_academy
    and_i_do_not_see_the_school_hogwarts_elementary
    and_the_only_schools_using_the_service_filter_is_checked

    when_i_select_the_all_schools_filter
    and_i_click_on_apply_filters
    then_i_see_the_find_schools_page
    and_i_see_the_school_springfield_elementary
    and_i_see_the_school_brixton_academy
    and_i_see_the_school_hogwarts_elementary
    and_the_all_schools_filter_is_checked
  end

  private

  def given_that_schools_exist
    @school_with_completed_eoi = create(:placements_school, name: "Springfield Elementary")
    @school_without_eoi = create(
      :placements_school,
      with_hosting_interest: false,
      expression_of_interest_completed: false,
      name: "Hogwarts Elementary",
    )
    @school_with_hosting_interest = create(
      :placements_school,
      name: "Brixton Academy",
      expression_of_interest_completed: false,
    )
  end

  def and_i_am_signed_in
    @provider = build(:placements_provider, name: "Aes Sedai Trust")

    sign_in_placements_user(organisations: [@provider])
  end

  def when_i_navigate_to_the_find_schools_page
    within ".app-primary-navigation__nav" do
      click_on "Find"
    end
  end

  def then_i_see_the_find_schools_page
    expect(page).to have_title("Find schools hosting placements - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Find")
    expect(page).to have_h1("Find schools hosting placements")
    expect(page).to have_h2("Filter")
  end

  def and_i_see_the_school_springfield_elementary
    expect(page).to have_h2("Springfield Elementary")
  end

  def and_i_see_the_school_brixton_academy
    expect(page).to have_h2("Brixton Academy")
  end

  def and_i_see_the_school_hogwarts_elementary
    expect(page).to have_h2("Hogwarts Elementary")
  end

  def and_i_do_not_see_the_school_hogwarts_elementary
    expect(page).not_to have_h2("Hogwarts Elementary")
  end

  def and_the_only_schools_using_the_service_filter_is_checked
    expect(page).to have_checked_field("Only schools using the service", type: :radio)
    expect(page).to have_unchecked_field("All schools", type: :radio)
  end

  def when_i_select_the_all_schools_filter
    choose "All schools"
  end

  def and_i_click_on_apply_filters
    click_on "Apply filters"
  end

  def and_the_all_schools_filter_is_checked
    expect(page).to have_checked_field("All schools", type: :radio)
    expect(page).to have_unchecked_field("Only schools using the service", type: :radio)
  end
end
