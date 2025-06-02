require "rails_helper"

RSpec.describe "Provider user removes themselves from the provider", service: :placements, type: :system do
  include ActiveJob::TestHelper

  around do |example|
    perform_enqueued_jobs { example.run }
  end

  scenario do
    given_a_provider_exists
    and_i_am_signed_in
    when_i_navigate_to_users
    then_i_am_see_the_users_index_page
    and_the_only_user_listed_is_myself

    when_i_click_on_myself
    then_i_see_the_user_details_page_for_myself
    and_i_do_not_see_the_delete_user_link
  end

  private

  def given_a_provider_exists
    @provider = create(:placements_provider, name: "The London Provider")
  end

  def and_i_am_signed_in
    sign_in_placements_user(organisations: [@provider])
  end

  def when_i_navigate_to_users
    within(primary_navigation) do
      click_on "Users"
    end
  end

  def then_i_am_see_the_users_index_page
    expect(page).to have_title("Users - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Users")
    expect(page).to have_h1("Users")
    expect(page).to have_paragraph(
      "Users are other members of staff at your organisation. Adding a user will allow them to access placement information.",
    )
    expect(page).to have_link("Add user", class: "govuk-button")
  end

  def and_the_only_user_listed_is_myself
    expect(page.all(".govuk-table__row").count).to eq(2) # includes header row
    expect(page).to have_table_row({
      "Name" => @current_user.full_name,
      "Email address" => @current_user.email,
    })
  end

  def when_i_click_on_myself
    click_on @current_user.full_name
  end

  def then_i_see_the_user_details_page_for_myself
    expect(page).to have_title("#{@current_user.full_name} - Manage school placements - GOV.UK")
    expect(page).to have_h1(@current_user.full_name)
    expect(page).to have_summary_list_row("First name", @current_user.first_name)
    expect(page).to have_summary_list_row("Last name", @current_user.last_name)
    expect(page).to have_summary_list_row("Email address", @current_user.email)
  end

  def and_i_do_not_see_the_delete_user_link
    expect(page).not_to have_link("Delete user", class: "app-link--destructive")
  end
end
