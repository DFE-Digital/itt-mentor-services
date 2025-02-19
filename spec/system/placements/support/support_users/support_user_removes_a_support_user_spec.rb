require "rails_helper"

RSpec.describe "Support users removes a support user",
               service: :placements, type: :system do
  include ActiveJob::TestHelper

  around do |example|
    perform_enqueued_jobs { example.run }
  end

  scenario do
    given_that_support_users_exist
    and_i_am_signed_in
    when_i_click_on_support_users_in_the_header_navigation
    then_i_see_the_support_users_index_page
    and_i_see_support_user_sarah_doe
    and_i_see_support_user_joe_bloggs

    when_i_click_on_sarah_doe
    then_i_see_the_support_user_details_for_sarah_doe

    when_i_click_on_delete_support_user
    then_i_see_the_are_you_sure_page

    when_i_click_on_remove_support_user
    then_i_see_the_support_users_index_page
    and_i_see_the_user_was_successfully_deleted
    and_i_do_not_see_support_user_sarah_doe
    and_i_see_support_user_joe_bloggs
  end

  private

  def given_that_support_users_exist
    @support_user_sarah = create(
      :placements_support_user,
      first_name: "Sarah",
      last_name: "Doe",
      email: "sarah_doe@education.gov.uk",
    )
    @support_user_joe = create(
      :placements_support_user,
      first_name: "Joe",
      last_name: "Bloggs",
      email: "joe_bloggs@education.gov.uk",
    )
  end

  def and_i_am_signed_in
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

  def and_i_see_support_user_sarah_doe
    expect(page).to have_table_row({
      "Name" => "Sarah Doe",
      "Email address" => "sarah_doe@education.gov.uk",
    })
  end

  def and_i_see_support_user_joe_bloggs
    expect(page).to have_table_row({
      "Name" => "Joe Bloggs",
      "Email address" => "joe_bloggs@education.gov.uk",
    })
  end

  def when_i_click_on_sarah_doe
    click_on "Sarah Doe"
  end

  def then_i_see_the_support_user_details_for_sarah_doe
    expect(page).to have_title("Sarah Doe - Manage school placements - GOV.UK")
    expect(page).to have_current_path(
      placements_support_support_user_path(@support_user_sarah),
    )
    expect(page).to have_h1("Sarah Doe")
    expect(page).to have_summary_list_row(
      "First name", "Sarah"
    )
    expect(page).to have_summary_list_row(
      "Last name", "Doe"
    )
    expect(page).to have_summary_list_row(
      "Email address", "sarah_doe@education.gov.uk"
    )
    expect(page).to have_link("Remove support user")
  end

  def when_i_click_on_delete_support_user
    click_on "Remove support user"
  end

  def then_i_see_the_are_you_sure_page
    expect(page).to have_title(
      "Are you sure you want to remove this support user? - Sarah Doe - Manage school placements - GOV.UK",
    )
    expect(page).to have_h1("Are you sure you want to remove this support user?")
    expect(page).to have_element(:span, text: "Sarah Doe", class: "govuk-caption-l")
    expect(page).to have_warning_text(
      "The support user will be sent an email to tell them you removed them from Manage school placements.",
    )
    expect(page).to have_button("Remove support user")
  end

  def when_i_click_on_remove_support_user
    click_on "Remove support user"
  end

  def and_i_see_the_user_was_successfully_deleted
    expect(page).to have_success_banner("Support user removed")
  end

  def and_i_do_not_see_support_user_sarah_doe
    expect(page).not_to have_table_row({
      "Name" => "Sarah Doe",
      "Email address" => "sarah_doe@education.gov.uk",
    })
  end
end
