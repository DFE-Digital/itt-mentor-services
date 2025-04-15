require "rails_helper"

RSpec.describe "Invite a user to a school", service: :claims, type: :system do
  include ActiveJob::TestHelper

  around do |example|
    perform_enqueued_jobs { example.run }
  end

  scenario "Claims user invites and views a user" do
    given_a_school_exists_with_claims_users
    and_i_am_signed_in

    when_i_navigate_to_the_claim_school_users_page
    then_i_see_the_claim_users_page
    and_i_select_add_user
    then_i_see_the_add_user_page

    when_i_fill_in_the_new_user_details
    and_i_select_continue
    then_i_see_the_confirm_user_details_page

    when_i_select_confirm_and_add_user
    then_i_see_the_claim_users_page_with_new_user
    and_an_email_has_been_sent_to_the_new_user

    when_i_select_the_new_user
    then_i_see_the_details_page_for_the_new_user
  end

  scenario "Claims user invites a user and enters invalid details" do
    given_a_school_exists_with_claims_users
    and_i_am_signed_in

    when_i_navigate_to_the_claim_school_users_page
    then_i_see_the_claim_users_page
    and_i_select_add_user
    then_i_see_the_add_user_page

    when_i_fill_in_invalid_user_email_details
    and_i_select_continue
    then_i_see_the_add_user_page_with_invalid_email_error
  end

  scenario "Claims user invites a user who already exists" do
    given_a_school_exists_with_claims_users
    and_i_am_signed_in

    when_i_navigate_to_the_claim_school_users_page
    then_i_see_the_claim_users_page
    and_i_select_add_user
    then_i_see_the_add_user_page

    when_i_fill_in_the_user_details_with_an_existing_user
    and_i_select_continue
    then_i_see_the_add_user_page_with_email_in_use_error
  end

  scenario "Claims user prevented from accessing user list of another school" do
    given_a_school_exists_with_claims_users
    and_given_a_second_school_exists
    and_i_am_signed_in_as_a_user_of_the_first_school

    then_i_am_prevented_from_viewing_the_second_schools_claim_user_page
  end

  scenario "Claims user edits answers via the back link" do
    given_a_school_exists_with_claims_users
    and_i_am_signed_in

    when_i_navigate_to_the_claim_school_users_page
    then_i_see_the_claim_users_page
    and_i_select_add_user
    then_i_see_the_add_user_page

    when_i_fill_in_the_new_user_details
    and_i_select_continue
    then_i_see_the_confirm_user_details_page

    when_i_select_back
    then_i_see_the_add_user_page_with_persisted_details
    and_i_edit_the_details
    and_i_select_continue

    then_i_see_the_confirm_user_details_page_with_new_details
    when_i_select_confirm_and_add_user
    then_i_see_the_claim_users_page_with_new_user_with_edited_details
    and_an_email_has_been_sent_to_the_new_user_with_edited_details

    when_i_select_the_edited_details_user
    then_i_see_the_details_page_for_the_edited_details_user
  end

  scenario "Claims user edits new user details via the change link" do
    given_a_school_exists_with_claims_users
    and_i_am_signed_in

    when_i_navigate_to_the_claim_school_users_page
    then_i_see_the_claim_users_page
    and_i_select_add_user
    then_i_see_the_add_user_page

    when_i_fill_in_the_new_user_details
    and_i_select_continue
    then_i_see_the_confirm_user_details_page

    when_i_select_change
    then_i_see_the_add_user_page_with_persisted_details
    and_i_edit_the_details
    and_i_select_continue

    then_i_see_the_confirm_user_details_page_with_new_details
    when_i_select_confirm_and_add_user
    then_i_see_the_claim_users_page_with_new_user_with_edited_details
    and_an_email_has_been_sent_to_the_new_user_with_edited_details

    when_i_select_the_edited_details_user
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

  def and_given_a_second_school_exists
    @townsend_highschool = create(
      :claims_school,
    )
  end

  def and_i_am_signed_in
    sign_in_claims_user(organisations: [@shelbyville_school])
  end
  alias_method :and_i_am_signed_in_as_a_user_of_the_first_school, :and_i_am_signed_in

  def then_i_am_prevented_from_viewing_the_second_schools_claim_user_page
    expect { visit claims_school_users_path(@townsend_highschool) }.to raise_error(ActiveRecord::RecordNotFound)
  end

  def and_an_email_has_been_sent_to_the_new_user
    email = ActionMailer::Base.deliveries.find do |delivery|
      delivery.to.include?("barry_garlow@education.gov.uk") && delivery.subject == "Invitation to join Claim funding for mentor training"
    end

    expect(email).not_to be_nil
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

  def and_i_edit_the_details
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
    visit claims_school_users_path(@shelbyville_school)
  end

  def then_i_see_the_claim_users_page
    expect(page).to have_title("Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Users")
    expect(page).to have_h1("Users")
    expect(page).to have_element(
      :a,
      text: "Add user",
      class: "govuk-button",
    )
    expect(page).to have_table_row({
      "Full name" => "Anne Wilson",
      "Email address" => "anne_wilson@education.gov.uk",
    })
    expect(page).to have_table_row({
      "Full name" => "Charles G",
      "Email address" => "charles_g@education.gov.uk",
    })
  end

  def then_i_see_the_add_user_page
    expect(page).to have_link("Back")
    expect(page).to have_title("Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Users")
    expect(page).to have_h1("User details")
    expect(page).to have_caption("User details")
    expect(page).to have_element(:input, id: "claims-add-user-wizard-user-step-first-name-field")
    expect(page).to have_element(:input, id: "claims-add-user-wizard-user-step-last-name-field")
    expect(page).to have_element(:input, id: "claims-add-user-wizard-user-step-email-field")
    expect(page).to have_button(
      text: "Continue",
      type: "submit",
      class: "govuk-button",
    )
  end

  def then_i_see_the_add_user_page_with_persisted_details
    expect(page).to have_link("Back")
    expect(page).to have_title("Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Users")
    expect(page).to have_h1("User details")
    expect(page).to have_caption("User details")
    expect(page).to have_element(:input, id: "claims-add-user-wizard-user-step-first-name-field", value: "Barry")
    expect(page).to have_element(:input, id: "claims-add-user-wizard-user-step-last-name-field", value: "Garlow")
    expect(page).to have_element(:input, id: "claims-add-user-wizard-user-step-email-field", value: "barry_garlow@education.gov.uk")
    expect(page).to have_button(
      text: "Continue",
      type: "submit",
      class: "govuk-button",
    )
  end

  def then_i_see_the_add_user_page_with_persisted_details_of_the_new_user
    expect(page).to have_link("Back")
    expect(page).to have_title("Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Users")
    expect(page).to have_h1("User details")
    expect(page).to have_caption("User details")
    expect(page).to have_element(:input, id: "claims-add-user-wizard-user-step-first-name-field", value: "Simon")
    expect(page).to have_element(:input, id: "claims-add-user-wizard-user-step-last-name-field", value: "Garlow")
    expect(page).to have_element(:input, id: "claims-add-user-wizard-user-step-email-field", value: "simon_garlow@education.gov.uk")
    expect(page).to have_button(
      text: "Continue",
      type: "submit",
      class: "govuk-button",
    )
  end

  def then_i_see_the_add_user_page_with_invalid_email_error
    expect(page).to have_link("Back")
    expect(page).to have_title("Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Users")
    expect(page).to have_h1("User details")
    expect(page).to have_caption("User details")
    expect(page).to have_validation_error("Enter an email address in the correct format, like name@example.com")
    expect(page).to have_element(:input, id: "claims-add-user-wizard-user-step-first-name-field", value: "James")
    expect(page).to have_element(:input, id: "claims-add-user-wizard-user-step-last-name-field", value: "Smith")
    expect(page).to have_element(:input, id: "claims-add-user-wizard-user-step-email-field-error", value: "not a valid email")
    expect(page).to have_element(:p, id: "claims-add-user-wizard-user-step-email-error", text: "Enter an email address in the correct format, like name@example.com")

    expect(page).to have_button(
      text: "Continue",
      type: "submit",
      class: "govuk-button",
    )
  end

  def then_i_see_the_add_user_page_with_email_in_use_error
    expect(page).to have_link("Back")
    expect(page).to have_title("Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Users")
    expect(page).to have_h1("User details")
    expect(page).to have_caption("User details")
    expect(page).to have_validation_error("Email address already in use")
    expect(page).to have_element(:input, id: "claims-add-user-wizard-user-step-first-name-field", value: "Charles")
    expect(page).to have_element(:input, id: "claims-add-user-wizard-user-step-last-name-field", value: "G")
    expect(page).to have_element(:input, id: "claims-add-user-wizard-user-step-email-field-error", value: "charles_g@education.gov.uk")
    expect(page).to have_element(:p, id: "claims-add-user-wizard-user-step-email-error", text: "Email address already in use")

    expect(page).to have_button(
      text: "Continue",
      type: "submit",
      class: "govuk-button",
    )
  end

  def then_i_see_the_claim_users_page_with_new_user
    expect(page).to have_title("Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Users")
    expect(page).to have_success_banner(
      "User added",
      "Barry is now able to view and create claims on behalf of Shelbyville Elementary",
    )
    expect(page).to have_h1("Users")
    expect(page).to have_element(
      :a,
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
      "Full name" => "Charles G",
      "Email address" => "charles_g@education.gov.uk",
    })
  end

  def then_i_see_the_claim_users_page_with_new_user_with_edited_details
    expect(page).to have_title("Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Users")
    expect(page).to have_success_banner(
      "User added",
      "Simon is now able to view and create claims on behalf of Shelbyville Elementary",
    )
    expect(page).to have_h1("Users")
    expect(page).to have_element(
      :a,
      text: "Add user",
      class: "govuk-button",
    )
    expect(page).to have_table_row({
      "Full name" => "Simon Garlow",
      "Email address" => "simon_garlow@education.gov.uk",
    })
    expect(page).to have_table_row({
      "Full name" => "Anne Wilson",
      "Email address" => "anne_wilson@education.gov.uk",
    })
    expect(page).to have_table_row({
      "Full name" => "Charles G",
      "Email address" => "charles_g@education.gov.uk",
    })
  end

  def then_i_see_the_confirm_user_details_page
    expect(page).to have_title("Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Users")
    expect(page).to have_h1("Confirm user details")
    expect(page).to have_h2("Details")
    expect(page).to have_caption("User details", class: "govuk-caption-l")
    expect(page).to have_summary_list_row("First name", "Barry", "Change")
    expect(page).to have_summary_list_row("Last name", "Garlow", "Change")
    expect(page).to have_summary_list_row("Email address", "barry_garlow@education.gov.uk", "Change")
    expect(page).to have_warning_text(
      "Barry Garlow will be sent an email to tell them you’ve added them to Shelbyville Elementary.",
    )
    expect(page).to have_button("Confirm and add user")
    expect(page).to have_link("Cancel", href: "/schools/#{@shelbyville_school.id}/users")
  end

  def then_i_see_the_confirm_user_details_page_with_new_details
    expect(page).to have_title("Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Users")
    expect(page).to have_h1("Confirm user details")
    expect(page).to have_h2("Details")
    expect(page).to have_caption("User details", class: "govuk-caption-l")
    expect(page).to have_summary_list_row("First name", "Simon", "Change")
    expect(page).to have_summary_list_row("Last name", "Garlow", "Change")
    expect(page).to have_summary_list_row("Email address", "simon_garlow@education.gov.uk", "Change")
    expect(page).to have_warning_text(
      "Simon Garlow will be sent an email to tell them you’ve added them to Shelbyville Elementary.",
    )
    expect(page).to have_button("Confirm and add user")
    expect(page).to have_link("Cancel", href: "/schools/#{@shelbyville_school.id}/users")
  end

  def then_i_see_the_details_page_for_the_new_user
    expect(page).to have_title("Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Users")
    expect(page).to have_h1("Barry Garlow")
    expect(page).to have_caption("Shelbyville Elementary")
    expect(page).to have_summary_list_row("First name", "Barry")
    expect(page).to have_summary_list_row("Last name", "Garlow")
    expect(page).to have_summary_list_row("Email address", "barry_garlow@education.gov.uk")
    expect(page).to have_element(
      :a,
      text: "Remove user",
      class: "govuk-link app-link app-link--destructive",
    )
  end

  def then_i_see_the_details_page_for_the_edited_details_user
    expect(page).to have_title("Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Users")
    expect(page).to have_h1("Simon Garlow")
    expect(page).to have_caption("Shelbyville Elementary")
    expect(page).to have_summary_list_row("First name", "Simon")
    expect(page).to have_summary_list_row("Last name", "Garlow")
    expect(page).to have_summary_list_row("Email address", "simon_garlow@education.gov.uk")
    expect(page).to have_element(
      :a,
      text: "Remove user",
      class: "govuk-link app-link app-link--destructive",
    )
  end

  def and_i_select_add_user
    click_on "Add user"
  end

  def when_i_select_back
    click_on "Back"
  end

  def and_i_select_continue
    click_on "Continue"
  end

  def when_i_select_change
    click_on "Change", match: :first
  end

  def when_i_select_confirm_and_add_user
    click_on "Confirm and add user"
  end

  def when_i_select_the_new_user
    click_on "Barry Garlow"
  end

  def when_i_select_the_edited_details_user
    click_on "Simon Garlow"
  end
end
