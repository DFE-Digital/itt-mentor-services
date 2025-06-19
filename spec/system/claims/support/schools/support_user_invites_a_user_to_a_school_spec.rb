require "rails_helper"

RSpec.describe "Support user invites a user to a school", service: :claims, type: :system do
  include ActiveJob::TestHelper

  around do |example|
    perform_enqueued_jobs { example.run }
  end

  scenario "Claims user invites and views a user" do
    given_a_school_exists_with_claims_users
    and_i_am_signed_in
    and_i_am_on_the_organisations_index_page
    and_i_select_shelbyville_elementary

    when_i_navigate_to_the_claim_school_users_page
    then_i_see_the_claim_users_page

    when_i_click_on_add_user
    then_i_see_the_add_user_page

    when_i_fill_in_invalid_user_email_details
    and_i_click_on_continue
    then_i_see_the_invalid_email_validation_error

    when_i_fill_in_the_user_details_with_an_existing_user
    and_i_click_on_continue
    then_i_see_the_add_user_page_with_email_in_use_error

    when_i_fill_in_the_new_user_details
    and_i_click_on_continue
    then_i_see_the_confirm_user_details_page

    when_i_click_on_back
    then_i_see_the_add_user_page_with_persisted_details

    when_i_edit_the_details
    and_i_click_on_continue
    then_i_see_the_confirm_user_details_page_with_new_details

    when_i_click_on_change
    then_i_see_the_add_user_page_with_persisted_details_of_the_new_user

    when_i_edit_the_details
    and_i_click_on_continue
    then_i_see_the_confirm_user_details_page_with_new_details

    when_i_select_confirm_and_add_user
    then_i_see_the_claim_users_page_with_new_user_with_edited_details
    and_an_email_has_been_sent_to_the_new_user_with_edited_details

    when_i_click_on_simon_garlow
    then_i_see_the_details_page_for_the_edited_details_user
  end

  private

  def given_a_school_exists_with_claims_users
    @user_anne = create(:claims_user, first_name: "Anne", last_name: "Wilson", email: "anne_wilson@education.gov.uk")
    @user_charles = create(:claims_user, first_name: "Charles", last_name: "G", email: "charles_g@education.gov.uk")

    @shelbyville_school = create(
      :claims_school,
      name: "Shelbyville Elementary",
      users: [@user_anne, @user_charles],
    )
  end

  def and_i_am_signed_in
    sign_in_claims_support_user
  end
  alias_method :and_i_am_signed_in_as_a_user_of_the_first_school, :and_i_am_signed_in

  def and_i_am_on_the_organisations_index_page
    expect(page).to have_current_path(claims_support_schools_path)
    expect(page).to have_title("Organisations (1) - Claim funding for mentor training - GOV.UK")
    expect(page).to have_h1("Organisations (1)")
    within(".organisation-search-results") do
      expect(page).to have_link("Shelbyville Elementary")
      expect(page).not_to have_link("Sherborne School")
      expect(page).not_to have_link("Royal Grammar School Guildford")
    end
  end

  def and_i_select_shelbyville_elementary
    click_on "Shelbyville Elementary"
  end

  def and_an_email_has_been_sent_to_the_new_user_with_edited_details
    email = ActionMailer::Base.deliveries.find do |delivery|
      delivery.to.include?("simon_garlow@education.gov.uk") && delivery.subject == "Invitation to join Claim funding for mentor training"
    end

    expect(email).not_to be_nil
  end

  def when_i_fill_in_the_new_user_details
    fill_in "First name", with: "Barry"
    fill_in "Last name", with: "Garlow"
    fill_in "Email", with: "barry_garlow@education.gov.uk"
  end

  def when_i_edit_the_details
    fill_in "First name", with: "Simon"
    fill_in "Last name", with: "Garlow"
    fill_in "Email", with: "simon_garlow@education.gov.uk"
  end

  def when_i_fill_in_the_user_details_with_an_existing_user
    fill_in "First name", with: "Charles"
    fill_in "Last name", with: "G"
    fill_in "Email", with: "charles_g@education.gov.uk"
  end

  def when_i_fill_in_invalid_user_email_details
    fill_in "First name", with: "James"
    fill_in "Last name", with: "Smith"
    fill_in "Email", with: "not a valid email"
  end

  def when_i_navigate_to_the_claim_school_users_page
    within(secondary_navigation) do
      click_on "Users"
    end
  end

  def then_i_see_the_claim_users_page
    expect(page).to have_title("Claim funding for mentor training - GOV.UK")
    expect(secondary_navigation).to have_current_item("Users")
    expect(page).to have_h1("Shelbyville Elementary")
    expect(page).to have_h2("Users")
    expect(page).to have_link(
      text: "Add user",
      class: "govuk-button",
    )
    expect(page).to have_table_row({
      "Name" => "Anne Wilson",
      "Email" => "anne_wilson@education.gov.uk",
    })
    expect(page).to have_table_row({
      "Name" => "Charles G",
      "Email" => "charles_g@education.gov.uk",
    })
  end

  def then_i_see_the_add_user_page
    expect(page).to have_link("Back")
    expect(page).to have_title("Claim funding for mentor training - GOV.UK")
    expect(page).to have_span_caption("Add user - Shelbyville Elementary")
    expect(page).to have_h1("User details")
    expect(page).to have_field("First name")
    expect(page).to have_field("Last name")
    expect(page).to have_field("Email address")
    expect(page).to have_button(
      text: "Continue",
      type: "submit",
      class: "govuk-button",
    )
  end

  def then_i_see_the_add_user_page_with_persisted_details
    expect(page).to have_link("Back")
    expect(page).to have_title("Claim funding for mentor training - GOV.UK")
    expect(page).to have_span_caption("Add user - Shelbyville Elementary")
    expect(page).to have_h1("User details")
    expect(page).to have_field("First name", with: "Barry")
    expect(page).to have_field("Last name", with: "Garlow")
    expect(page).to have_field("Email", with: "barry_garlow@education.gov.uk")
    expect(page).to have_button(
      text: "Continue",
      type: "submit",
      class: "govuk-button",
    )
  end

  def then_i_see_the_add_user_page_with_persisted_details_of_the_new_user
    expect(page).to have_link("Back")
    expect(page).to have_title("Claim funding for mentor training - GOV.UK")
    expect(page).to have_span_caption("Add user - Shelbyville Elementary")
    expect(page).to have_h1("User details")
    expect(page).to have_field("First name", with: "Simon")
    expect(page).to have_field("Last name", with: "Garlow")
    expect(page).to have_field("Email", with: "simon_garlow@education.gov.uk")
    expect(page).to have_button(
      text: "Continue",
      type: "submit",
      class: "govuk-button",
    )
  end

  def then_i_see_the_invalid_email_validation_error
    expect(page).to have_validation_error("Enter an email address in the correct format, like name@example.com")
  end

  def then_i_see_the_add_user_page_with_email_in_use_error
    expect(page).to have_link("Back")
    expect(page).to have_title("Claim funding for mentor training - GOV.UK")
    expect(page).to have_span_caption("Add user - Shelbyville Elementary")
    expect(page).to have_h1("User details")
    expect(page).to have_validation_error("Email address already in use")
    expect(page).to have_field("First name", with: "Charles")
    expect(page).to have_field("Last name", with: "G")
    expect(page).to have_field("Email", with: "charles_g@education.gov.uk")

    expect(page).to have_button(
      text: "Continue",
      type: "submit",
      class: "govuk-button",
    )
  end

  def then_i_see_the_claim_users_page_with_new_user
    expect(page).to have_title("Claim funding for mentor training - GOV.UK")
    expect(page).to have_success_banner(
      "User added",
      "Barry is now able to view and create claims on behalf of Shelbyville Elementary",
    )
    expect(page).to have_h1("Shelbyville Elementary")
    expect(page).to have_h2("Users")
    expect(page).to have_link(
      text: "Add user",
      class: "govuk-button",
    )
    expect(page).to have_table_row({
      "Name" => "Barry Garlow",
      "Email" => "barry_garlow@education.gov.uk",
    })
    expect(page).to have_table_row({
      "Name" => "Anne Wilson",
      "Email" => "anne_wilson@education.gov.uk",
    })
    expect(page).to have_table_row({
      "Name" => "Charles G",
      "Email" => "charles_g@education.gov.uk",
    })
  end

  def then_i_see_the_claim_users_page_with_new_user_with_edited_details
    expect(page).to have_title("Claim funding for mentor training - GOV.UK")
    expect(page).to have_success_banner("User added")
    expect(page).to have_h1("Shelbyville Elementary")
    expect(page).to have_h2("Users")
    expect(page).to have_link(
      text: "Add user",
      class: "govuk-button",
    )
    expect(page).to have_table_row({
      "Name" => "Simon Garlow",
      "Email" => "simon_garlow@education.gov.uk",
    })
    expect(page).to have_table_row({
      "Name" => "Anne Wilson",
      "Email" => "anne_wilson@education.gov.uk",
    })
    expect(page).to have_table_row({
      "Name" => "Charles G",
      "Email" => "charles_g@education.gov.uk",
    })
  end

  def then_i_see_the_confirm_user_details_page
    expect(page).to have_title("Claim funding for mentor training - GOV.UK")
    expect(page).to have_h1("Confirm user details")
    expect(page).to have_h2("Details")
    expect(page).to have_span_caption("Add user - Shelbyville Elementary")
    expect(page).to have_summary_list_row("First name", "Barry", "Change")
    expect(page).to have_summary_list_row("Last name", "Garlow", "Change")
    expect(page).to have_summary_list_row("Email", "barry_garlow@education.gov.uk", "Change")
    expect(page).to have_warning_text(
      "Barry Garlow will be sent an email to tell them you’ve added them to Shelbyville Elementary.",
    )
    expect(page).to have_button("Confirm and add user")
    expect(page).to have_link("Cancel", href: "/support/schools/#{@shelbyville_school.id}/users")
  end

  def then_i_see_the_confirm_user_details_page_with_new_details
    expect(page).to have_title("Claim funding for mentor training - GOV.UK")
    expect(page).to have_h1("Confirm user details")
    expect(page).to have_h2("Details")
    expect(page).to have_span_caption("Add user - Shelbyville Elementary")
    expect(page).to have_summary_list_row("First name", "Simon", "Change")
    expect(page).to have_summary_list_row("Last name", "Garlow", "Change")
    expect(page).to have_summary_list_row("Email", "simon_garlow@education.gov.uk", "Change")
    expect(page).to have_warning_text(
      "Simon Garlow will be sent an email to tell them you’ve added them to Shelbyville Elementary.",
    )
    expect(page).to have_button("Confirm and add user")
    expect(page).to have_link("Cancel", href: "/support/schools/#{@shelbyville_school.id}/users")
  end

  def then_i_see_the_details_page_for_the_edited_details_user
    expect(page).to have_title("Claim funding for mentor training - GOV.UK")
    expect(page).to have_h1("Simon Garlow")
    expect(page).to have_span_caption("Shelbyville Elementary")
    expect(page).to have_summary_list_row("First name", "Simon")
    expect(page).to have_summary_list_row("Last name", "Garlow")
    expect(page).to have_summary_list_row("Email", "simon_garlow@education.gov.uk")
    expect(page).to have_link(
      text: "Remove user",
      class: "govuk-link app-link app-link--destructive",
    )
  end

  def when_i_click_on_add_user
    click_on "Add user"
  end

  def when_i_click_on_back
    click_on "Back"
  end

  def and_i_click_on_continue
    click_on "Continue"
  end

  def when_i_click_on_change
    click_on "Change First name"
  end

  def when_i_select_confirm_and_add_user
    click_on "Confirm and add user"
  end

  def when_i_click_on_simon_garlow
    click_on "Simon Garlow"
  end
end
