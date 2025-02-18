require "rails_helper"

RSpec.describe "Support user views the details of a provider user", service: :placements, type: :system do
  scenario do
    given_that_provider_users_exist
    and_i_am_signed_in
    when_i_click_on_best_practice_network
    and_i_click_users_in_the_primary_navigation
    then_i_see_the_users_index_page_for_best_practice_network
    and_i_see_user_joe_bloggs
    and_i_see_user_sarah_doe
    and_i_do_not_see_user_john_smith

    when_i_click_on_joe_bloggs
    then_i_see_the_user_details_for_joe_bloggs
  end

  private

  def given_that_provider_users_exist
    @bpn_provider = create(
      :placements_provider,
      :best_practice_network,
    )
    @user_joe_bloggs = create(
      :placements_user,
      first_name: "Joe",
      last_name: "Bloggs",
      providers: [@bpn_provider],
    )
    @user_sarah_doe = create(
      :placements_user,
      first_name: "Sarah",
      last_name: "Doe",
      providers: [@bpn_provider],
    )

    @niot_provider = create(
      :placements_provider,
      :niot,
    )
    @user_john_smith = create(
      :placements_user,
      first_name: "John",
      last_name: "Smith",
      providers: [@niot_provider],
    )
  end

  def and_i_am_signed_in
    sign_in_placements_support_user
  end

  def when_i_click_on_best_practice_network
    click_on "Best Practice Network"
  end

  def and_i_click_users_in_the_primary_navigation
    within(primary_navigation) do
      click_on "Users"
    end
  end

  def then_i_see_the_users_index_page_for_best_practice_network
    expect(page).to have_title("Users - Manage school placements - GOV.UK")
    expect(page).to have_h1("Users")
    expect(page).to have_element(:span, text: "Best Practice Network")
    expect(page).to have_current_path(placements_provider_users_path(@bpn_provider))
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
end
