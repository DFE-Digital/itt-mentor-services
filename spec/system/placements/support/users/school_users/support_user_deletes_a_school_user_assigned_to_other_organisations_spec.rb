require "rails_helper"

RSpec.describe "Support user deletes a school user assigned to other organisations",
               service: :placements,
               type: :system do
  scenario do
    given_that_school_users_exist
    and_i_am_signed_in
    when_i_click_on_ashford_school
    and_i_click_users_in_the_primary_navigation
    then_i_see_the_users_index_page_for_ashford_school
    and_i_see_user_joe_bloggs
    and_i_see_user_sarah_doe

    when_i_click_on_joe_bloggs
    then_i_see_the_user_details_for_joe_bloggs

    when_i_click_on_delete_user
    then_i_see_the_are_you_sure_page

    when_i_click_on_delete_user
    then_i_see_the_users_index_page_for_ashford_school
    and_i_see_the_user_was_successfully_deleted
    and_i_do_not_see_user_joe_bloggs
    and_i_see_user_sarah_doe

    when_i_click_on_change_organisation
    and_i_click_on_royal_grammar_school_guildford
    and_i_click_users_in_the_primary_navigation
    then_i_see_the_users_index_page_for_royal_grammar_school_guildford
    and_i_see_user_joe_bloggs

    when_i_click_on_change_organisation
    when_i_click_on_best_practice_network
    and_i_click_users_in_the_primary_navigation
    then_i_see_the_users_index_page_for_best_practice_network
    and_i_see_user_joe_bloggs
  end

  private

  def given_that_school_users_exist
    @ashford_school = create(
      :placements_school,
      name: "Ashford School",
    )
    @guildford_school = create(
      :placements_school,
      name: "Royal Grammar School Guildford",
    )
    @bpn_provider = create(
      :placements_provider,
      :best_practice_network,
    )
    @user_joe_bloggs = create(
      :placements_user,
      first_name: "Joe",
      last_name: "Bloggs",
      schools: [@ashford_school, @guildford_school],
      providers: [@bpn_provider],
    )
    @user_sarah_doe = create(
      :placements_user,
      first_name: "Sarah",
      last_name: "Doe",
      schools: [@ashford_school],
    )
  end

  def and_i_am_signed_in
    sign_in_placements_support_user
  end

  def when_i_click_on_ashford_school
    click_on "Ashford School"
  end

  def and_i_click_users_in_the_primary_navigation
    within(primary_navigation) do
      click_on "Users"
    end
  end

  def then_i_see_the_users_index_page_for_ashford_school
    expect(page).to have_title("Users - Manage school placements - GOV.UK")
    expect(page).to have_h1("Users")
    expect(page).to have_element(:span, text: "Ashford School")
    expect(page).to have_current_path(placements_school_users_path(@ashford_school))
    expect(page).to have_link("Add user")
  end

  def and_i_see_user_joe_bloggs
    expect(page).to have_table_row({
      "Name" => "Joe Bloggs",
      "Email address" => @user_joe_bloggs.email,
    })
  end

  def and_i_see_user_sarah_doe
    expect(page).to have_table_row({
      "Name" => "Sarah Doe",
      "Email address" => @user_sarah_doe.email,
    })
  end

  def and_i_do_not_see_user_john_smith
    expect(page).not_to have_table_row({
      "Name" => "John Smith",
      "Email address" => @user_john_smith.email,
    })
  end

  def when_i_click_on_joe_bloggs
    click_on "Joe Bloggs"
  end

  def then_i_see_the_user_details_for_joe_bloggs
    expect(page).to have_title("Joe Bloggs - Manage school placements - GOV.UK")
    expect(page).to have_h1("Joe Bloggs")
    expect(page).to have_current_path(placements_school_user_path(@ashford_school, @user_joe_bloggs))
    expect(page).to have_summary_list_row(
      "First name", "Joe"
    )
    expect(page).to have_summary_list_row(
      "Last name", "Bloggs"
    )
    expect(page).to have_summary_list_row(
      "Email address", @user_joe_bloggs.email
    )
    expect(page).to have_link("Delete user")
  end

  def when_i_click_on_delete_user
    click_on "Delete user"
  end

  def then_i_see_the_are_you_sure_page
    expect(page).to have_title(
      "Are you sure you want to delete this user? - Joe Bloggs - Manage school placements - GOV.UK",
    )
    expect(page).to have_h1("Are you sure you want to delete this user?")
    expect(page).to have_element(:span, text: "Joe Bloggs", class: "govuk-caption-l")
    expect(page).to have_element(
      :p,
      text: "Joe Bloggs will no longer be able to view, create or manage placements at your school.",
    )
    expect(page).to have_warning_text(
      "The user will be sent an email to tell them you deleted them from Ashford School",
    )
    expect(page).to have_button("Delete user")
  end

  def when_i_click_on_delete_user
    click_on "Delete user"
  end

  def and_i_see_the_user_was_successfully_deleted
    expect(page).to have_success_banner("User deleted")
  end

  def and_i_do_not_see_user_joe_bloggs
    expect(page).not_to have_table_row({
      "Name" => "Joe Bloggs",
      "Email address" => @user_joe_bloggs.email,
    })
  end

  def when_i_click_on_change_organisation
    click_on "Change organisation"
  end

  def and_i_click_on_royal_grammar_school_guildford
    click_on "Royal Grammar School Guildford"
  end

  def then_i_see_the_users_index_page_for_royal_grammar_school_guildford
    expect(page).to have_title("Users - Manage school placements - GOV.UK")
    expect(page).to have_h1("Users")
    expect(page).to have_element(:span, text: "Royal Grammar School Guildford")
    expect(page).to have_current_path(placements_school_users_path(@guildford_school))
    expect(page).to have_link("Add user")
  end

  def when_i_click_on_best_practice_network
    click_on "Best Practice Network"
  end

  def then_i_see_the_users_index_page_for_best_practice_network
    expect(page).to have_title("Users - Manage school placements - GOV.UK")
    expect(page).to have_h1("Users")
    expect(page).to have_element(:span, text: "Best Practice Network")
    expect(page).to have_current_path(placements_provider_users_path(@bpn_provider))
    expect(page).to have_link("Add user")
  end
end
