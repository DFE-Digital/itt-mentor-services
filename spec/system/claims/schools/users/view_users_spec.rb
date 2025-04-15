require "rails_helper"

RSpec.describe "Claims user views their school's user list", service: :claims, type: :system do
  scenario do
    given_a_school_exists_with_claims_users
    and_i_am_signed_in_as_a_user

    when_i_navigate_to_the_claim_school_users_page
    then_i_see_the_claim_users_page_with_all_users
  end

  private

  def given_a_school_exists_with_claims_users
    @user_anne = create(:claims_user, first_name: "Anne", last_name: "Wilson", email: "anne_wilson@education.gov.uk")
    @user_charles = create(:claims_user, first_name: "Charles", last_name: "G", email: "charles_g@education.gov.uk")
    @user_bobby_g = create(:claims_user, first_name: "Bobby", last_name: "G", email: "bobby_g@education.gov.uk")
    @user_bobby_a = create(:claims_user, first_name: "Bobby", last_name: "A", email: "bobby_a@education.gov.uk")

    @shelbyville_school = create(
      :claims_school,
      name: "Shelbyville Elementary",
      users: [@user_anne, @user_charles, @user_bobby_g, @user_bobby_a],
    )
  end

  def and_i_am_signed_in_as_a_user
    sign_in_claims_user(organisations: [@shelbyville_school])
  end

  def when_i_navigate_to_the_claim_school_users_page
    within(primary_navigation) do
      click_on "Users"
    end
  end

  def then_i_see_the_claim_users_page_with_all_users
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
      "Full name" => "Bobby G",
      "Email address" => "bobby_g@education.gov.uk",
    })
    expect(page).to have_table_row({
      "Full name" => "Bobby A",
      "Email address" => "bobby_a@education.gov.uk",
    })
  end

  def and_i_click_on_add_user
    click_on "Add user"
  end

  def then_i_fill_in_the_new_user_details
    fill_in "First name", with: "Barry"
    fill_in "Last name", with: "Garlow"
    fill_in "Email", with: "barry_garlow@education.gov.uk"
  end

  def and_i_click_on_continue
    click_on "Continue"
  end

  def then_i_see_the_claim_users_page_with_new_user
    expect(page).to have_title("Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Users")
    expect(page).to have_success_banner(
      "User added",
      "Barry is now able to view and create claims on behalf of Shelbyville Elementary",
    )
    expect(page).to have_h1("Users")
    expect(page).to have_link(
      text: "Add user",
      class: "govuk-button",
    )
    expect(page).to have_table_row({
      "Full name" => "Barry Garlow",
      "Email address" => "barry_garlow@education.gov.uk",
    })
    expect(page).to have_table_row({
      "Full name" => "Anne Wilson",
      "Email address" => "anne_wilson@education.gov.uk",
    })
    expect(page).to have_table_row({
      "Full name" => "Bobby G",
      "Email address" => "bobby_g@education.gov.uk",
    })
    expect(page).to have_table_row({
      "Full name" => "Bobby A",
      "Email address" => "bobby_a@education.gov.uk",
    })
  end

  def then_i_see_the_confirm_user_details_page
    expect(page).to have_title("Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Users")
    expect(page).to have_h1("Confirm user details")
    expect(page).to have_h2("Details")
    expect(page).to have_span_caption("User details", class: "govuk-caption-l")
    expect(page).to have_summary_list_row("First name", "Barry", "Change")
    expect(page).to have_summary_list_row("Last name", "Garlow", "Change")
    expect(page).to have_summary_list_row("Email address", "barry_garlow@education.gov.uk", "Change")
    expect(page).to have_warning_text(
      "Barry Garlow will be sent an email to tell them you’ve added them to Shelbyville Elementary.",
    )
    expect(page).to have_button("Confirm and add user")
    expect(page).to have_link("Cancel", href: "/schools/#{@shelbyville_school.id}/users")
  end

  def and_i_select_confirm_and_add_user
    click_on "Confirm and add user"
  end

  def when_i_select_the_new_user
    click_on "Barry Garlow"
  end

  def then_i_see_the_details_page_for_the_new_user
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
end
