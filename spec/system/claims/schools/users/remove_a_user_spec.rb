require "rails_helper"

RSpec.describe "Remove a user", service: :claims, type: :system do
  scenario "Claims user removes user from a school" do
    given_a_school_exists_with_claims_users
    and_i_am_signed_in

    and_i_navigate_to_my_own_user_removal_page
    then_i_am_alerted_that_i_cannot_perform_this_action

    when_i_navigate_to_users
    then_i_see_the_claim_users_page

    when_i_click_on_my_own_name
    then_i_see_my_own_details_page_with_no_remove_user_link

    when_i_navigate_to_users
    then_i_see_the_claim_users_page

    when_i_click_on_barry_garlow
    then_i_see_the_details_page_for_the_user

    when_i_click_on_remove_user
    then_i_see_the_removal_confirmation_page

    when_i_click_on_remove_user
    then_i_see_the_claim_users_page_with_the_user_removed
  end

  private

  def given_a_school_exists_with_claims_users
    @user_anne = create(:claims_user, first_name: "Anne", last_name: "Wilson", email: "anne_wilson@education.gov.uk")
    @user_barry = create(:claims_user, first_name: "Barry", last_name: "Garlow", email: "barry_garlow@education.gov.uk")

    @shelbyville_school = create(
      :claims_school,
      name: "Shelbyville Elementary",
      users: [@user_anne, @user_barry],
    )
  end

  def and_i_am_signed_in
    sign_in_as(@user_anne)
  end

  def when_i_navigate_to_users
    within(primary_navigation) do
      click_on "Users"
    end
  end

  def when_i_click_on_barry_garlow
    click_on "Barry Garlow"
  end

  def when_i_click_on_my_own_name
    click_on "Anne Wilson"
  end

  def then_i_see_the_claim_users_page
    expect(page).to have_title("Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Users")
    expect(page).to have_h1("Users")
    expect(page).to have_link(
      text: "Add user",
      class: "govuk-button",
    )
    expect(page).to have_table_row({
      "Full name" => "Anne Wilson",
      "Email address" => "anne_wilson@education.gov.uk",
    })
    expect(page).to have_table_row({
      "Full name" => "Barry Garlow",
      "Email address" => "barry_garlow@education.gov.uk",
    })
  end

  def then_i_see_the_details_page_for_the_user
    expect(page).to have_title("Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Users")
    expect(page).to have_h1("Barry Garlow")
    expect(page).to have_span_caption("Shelbyville Elementary")
    expect(page).to have_summary_list_row("First name", "Barry")
    expect(page).to have_summary_list_row("Last name", "Garlow")
    expect(page).to have_summary_list_row("Email address", "barry_garlow@education.gov.uk")
    expect(page).to have_link(
      text: "Remove user",
      class: "govuk-link app-link app-link--destructive",
    )
  end

  def then_i_see_my_own_details_page_with_no_remove_user_link
    expect(page).to have_title("Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Users")
    expect(page).to have_h1("Anne Wilson")
    expect(page).to have_span_caption("Shelbyville Elementary")
    expect(page).to have_summary_list_row("First name", "Anne")
    expect(page).to have_summary_list_row("Last name", "Wilson")
    expect(page).to have_summary_list_row("Email address", "anne_wilson@education.gov.uk")
    expect(page).not_to have_link(
      text: "Remove user",
      class: "govuk-link app-link app-link--destructive",
    )
  end

  def then_i_see_the_removal_confirmation_page
    expect(page).to have_title("Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Organisations")
    expect(page).to have_h1("Are you sure you want to remove this user?")
    expect(page).to have_span_caption("Barry Garlow")
    expect(page).to have_warning_text(
      "Barry Garlow will be sent an email to tell them you removed them from Shelbyville Elementary",
    )
    expect(page).to have_button(
      text: "Remove user",
      class: "govuk-button govuk-button--warning",
    )
    expect(page).to have_link(
      text: "Cancel",
      class: "govuk-link",
    )
  end

  def when_i_click_on_remove_user
    click_on "Remove user"
  end

  def then_i_see_the_claim_users_page_with_the_user_removed
    expect(page).to have_title("Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Users")
    expect(page).to have_h1("Users")
    expect(page).to have_link(
      text: "Add user",
      class: "govuk-button",
    )
    expect(page).to have_table_row({
      "Full name" => "Anne Wilson",
      "Email address" => "anne_wilson@education.gov.uk",
    })
    expect(page).not_to have_table_row({
      "Full name" => "Barry Garlow",
      "Email address" => "barry_garlow@education.gov.uk",
    })
    expect(page).to have_success_banner("User removed")
  end

  def then_i_am_alerted_that_i_cannot_perform_this_action
    expect(page).to have_important_banner("You cannot perform this action")
  end

  def and_i_navigate_to_my_own_user_removal_page
    visit remove_claims_school_user_path(@shelbyville_school, @user_anne)
  end
end
