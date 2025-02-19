require "rails_helper"

RSpec.describe "Support user views a support user", service: :placements, type: :system do
  scenario do
    given_i_am_signed_in
    when_i_click_on_support_users_in_the_header_navigation
    then_i_see_the_support_users_index_page
    and_i_see_myself_as_a_support_user

    when_i_click_on_my_name
    then_i_see_the_support_user_details_for_myself
    and_i_do_not_see_a_link_to_remove_me_as_a_support_user
  end

  private

  def given_i_am_signed_in
    sign_in_placements_support_user
  end

  def when_i_click_on_support_users_in_the_header_navigation
    within("#navigation") do
      click_on "Support users"
    end
  end

  def then_i_see_the_support_users_index_page
    expect(page).to have_title("Support users - Manage school placements - GOV.UK")
    expect(page).to have_h1("Support users")
    expect(page).to have_current_path(placements_support_support_users_path)
    expect(page).to have_link("Add support user")
  end

  def and_i_see_myself_as_a_support_user
    expect(page).to have_table_row({
      "Name" => @current_user.full_name,
      "Email address" => @current_user.email,
    })
  end

  def when_i_click_on_my_name
    click_on @current_user.full_name
  end

  def then_i_see_the_support_user_details_for_myself
    expect(page).to have_title("#{@current_user.full_name} - Manage school placements - GOV.UK")
    expect(page).to have_current_path(
      placements_support_support_user_path(@current_user),
    )
    expect(page).to have_h1(@current_user.full_name)
    expect(page).to have_summary_list_row(
      "First name", @current_user.first_name
    )
    expect(page).to have_summary_list_row(
      "Last name", @current_user.last_name
    )
    expect(page).to have_summary_list_row(
      "Email address", @current_user.email
    )
  end

  def and_i_do_not_see_a_link_to_remove_me_as_a_support_user
    expect(page).not_to have_link("Remove support user")
  end
end
