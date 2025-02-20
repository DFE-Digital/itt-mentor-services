require "rails_helper"

RSpec.describe "Support user re-adds a discarded support user with different details",
               service: :placements, type: :system do
  include ActiveJob::TestHelper

  around do |example|
    perform_enqueued_jobs { example.run }
  end

  scenario do
    given_a_discarded_support_user_exist
    and_i_am_signed_in
    when_i_click_on_support_users_in_the_header_navigation
    then_i_see_the_support_users_index_page
    and_i_do_not_see_support_user_joe_bloggs

    when_i_click_on_add_support_user
    then_i_see_the_personal_details_form

    when_i_enter_different_details_for_the_discarded_support_user
    and_i_click_on_continue
    then_i_see_the_check_your_answers_page

    when_i_click_on_add_support_user
    then_i_see_the_support_users_index_page
    and_i_see_joe_bloggs_has_been_added_successfully
    and_i_see_support_user_joseph_blogs
    and_joe_bloggs_is_sent_an_email
  end

  private

  def given_a_discarded_support_user_exist
    @support_user_joe = create(
      :placements_support_user,
      :discarded,
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

  def and_i_do_not_see_support_user_joe_bloggs
    expect(page).not_to have_table_row({
      "Name" => "Joe Bloggs",
      "Email address" => "joe_bloggs@education.gov.uk",
    })
  end

  def when_i_click_on_add_support_user
    click_on "Add support user"
  end

  def then_i_see_the_personal_details_form
    expect(page).to have_title("Personal details - Add support user - Manage school placements - GOV.UK")
    expect(page).to have_element(:span, text: "Add support user", class: "govuk-caption-l")
    expect(page).to have_h1("Personal details")
    expect(page).to have_element(:div, text: "Email must be a valid Department for Education address, like name@education.gov.uk.", class: "govuk-hint")
    expect(page).to have_button("Continue")
    expect(page).to have_link("Cancel", href: "/support/support_users")
  end

  def when_i_enter_different_details_for_the_discarded_support_user
    fill_in "First name", with: "Joseph"
    fill_in "Last name", with: "Blogs"
    fill_in "Email address", with: "joe_bloggs@education.gov.uk"
  end

  def and_i_click_on_continue
    click_on "Continue"
  end

  def then_i_see_the_check_your_answers_page
    expect(page).to have_title("Check your answers - Add support user - Manage school placements - GOV.UK")
    expect(page).to have_element(:span, text: "Add support user", class: "govuk-caption-l")
    expect(page).to have_h1("Check your answers")
    expect(page).to have_warning_text(
      "The support user will be sent an email to tell them you’ve added them to Manage school placements.",
    )
    expect(page).to have_button("Add support user")
    expect(page).to have_link("Cancel", href: "/support/support_users")

    expect(page).to have_summary_list_row(
      "First name", "Joseph"
    )
    expect(page).to have_summary_list_row(
      "Last name", "Blogs"
    )
    expect(page).to have_summary_list_row(
      "Email address", "joe_bloggs@education.gov.uk"
    )
  end

  def and_i_see_joe_bloggs_has_been_added_successfully
    expect(page).to have_success_banner(
      "Support user added",
    )
  end

  def and_i_see_support_user_joseph_blogs
    expect(page).to have_table_row({
      "Name" => "Joseph Blogs",
      "Email address" => "joe_bloggs@education.gov.uk",
    })
  end

  def and_joe_bloggs_is_sent_an_email
    email = ActionMailer::Base.deliveries.find do |delivery|
      delivery.to.include?("joe_bloggs@education.gov.uk") &&
        delivery.subject == "Your invite to the Manage school placements service"
    end
    expect(email).not_to be_nil
  end
end
