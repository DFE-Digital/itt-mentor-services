require "rails_helper"

RSpec.describe "Provider user manages users", service: :claims, type: :system do
  include ActiveJob::TestHelper

  around do |example|
    perform_enqueued_jobs { example.run }
  end

  scenario "provider user adds a user" do
    given_a_provider_exists_with_users
    and_i_am_signed_in_as_anne
    and_i_visit_the_claims_page

    when_i_navigate_to_users
    then_i_see_the_users_page

    when_i_click_on_add_user
    and_i_fill_in_the_details_of_an_existing_user
    and_i_click_on_continue
    then_i_see_the_email_in_use_error

    when_i_fill_in_the_new_user_details
    and_i_click_on_continue
    then_i_see_the_confirm_user_details_page

    when_i_click_on_confirm_and_add_user
    then_i_see_the_users_page_with_the_new_user
    and_the_new_user_has_been_sent_an_invitation_email

    when_i_click_on_simon_garlow
    then_i_see_simon_garlows_details_page
  end

  scenario "provider user removes a user" do
    given_a_provider_exists_with_users
    and_i_am_signed_in_as_anne
    and_i_visit_the_users_page

    when_i_click_on_anne_wilson
    then_i_see_my_own_details_page_without_a_remove_link

    when_i_navigate_to_users
    and_i_click_on_barry_garlow
    and_i_click_on_remove_user
    then_i_see_the_removal_confirmation_page

    when_i_click_on_remove_user
    then_i_see_the_users_page_without_barry_garlow
    and_barry_garlow_has_been_sent_a_removal_email
  end

  scenario "provider user cannot view another provider's users" do
    given_a_provider_exists_with_users
    and_another_provider_exists
    and_i_am_signed_in_as_anne
    then_i_cannot_view_the_other_providers_users
  end

  private

  def given_a_provider_exists_with_users
    @provider = create(:claims_provider, name: "North Star SCITT")
    @user_anne = create(:claims_provider_user, first_name: "Anne", last_name: "Wilson", email: "anne_wilson@education.gov.uk", providers: [@provider])
    @user_barry = create(:claims_provider_user, first_name: "Barry", last_name: "Garlow", email: "barry_garlow@education.gov.uk", providers: [@provider])
  end

  def and_another_provider_exists
    @other_provider = create(:claims_provider, name: "South Star SCITT")
  end

  def and_i_am_signed_in_as_anne
    sign_in_as(@user_anne)
  end

  def and_i_visit_the_claims_page
    visit claims_provider_claims_path(@provider)
  end

  def and_i_visit_the_users_page
    visit claims_provider_users_path(@provider)
  end

  def when_i_navigate_to_users
    within(primary_navigation) do
      click_on "Users"
    end
  end

  def then_i_see_the_users_page
    expect(page).to have_title("Users - Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Users")
    expect(page).to have_h1("Users")
    expect(page).to have_link("Add user", class: "govuk-button")
    expect(page).to have_table_row("Full name" => "Anne Wilson", "Email address" => "anne_wilson@education.gov.uk")
    expect(page).to have_table_row("Full name" => "Barry Garlow", "Email address" => "barry_garlow@education.gov.uk")
  end

  def when_i_click_on_add_user
    click_on "Add user"
  end

  def and_i_fill_in_the_details_of_an_existing_user
    fill_in "First name", with: "Barry"
    fill_in "Last name", with: "Garlow"
    fill_in "Email", with: "barry_garlow@education.gov.uk"
  end

  def and_i_click_on_continue
    click_on "Continue"
  end

  def then_i_see_the_email_in_use_error
    expect(page).to have_title("Error: Invite a new user - User details - Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Users")
    expect(page).to have_validation_error("Email address already in use")
  end

  def when_i_fill_in_the_new_user_details
    fill_in "First name", with: "Simon"
    fill_in "Last name", with: "Garlow"
    fill_in "Email", with: "simon_garlow@education.gov.uk"
  end

  def then_i_see_the_confirm_user_details_page
    expect(page).to have_title("Check your answers - User details - Claim funding for mentor training - GOV.UK")
    expect(page).to have_h1("Confirm user details")
    expect(page).to have_paragraph("Once added, Simon will be able to view and audit claims on behalf of your organisation.")
    expect(page).to have_summary_list_row("First name", "Simon", "Change")
    expect(page).to have_summary_list_row("Last name", "Garlow", "Change")
    expect(page).to have_summary_list_row("Email address", "simon_garlow@education.gov.uk", "Change")
    expect(page).to have_warning_text("Simon Garlow will be sent an email to tell them you’ve added them to North Star SCITT.")
    expect(page).to have_link("Cancel", href: "/providers/#{@provider.id}/users")
  end

  def when_i_click_on_confirm_and_add_user
    click_on "Confirm and add user"
  end

  def then_i_see_the_users_page_with_the_new_user
    expect(page).to have_success_banner(
      "User added",
      "Simon is now able to view and audit claims on behalf of North Star SCITT",
    )
    expect(page).to have_table_row("Full name" => "Simon Garlow", "Email address" => "simon_garlow@education.gov.uk")
    expect(Claims::ProviderUser.find_by(email: "simon_garlow@education.gov.uk").providers).to contain_exactly(@provider)
  end

  def and_the_new_user_has_been_sent_an_invitation_email
    email = ActionMailer::Base.deliveries.find do |delivery|
      delivery.to.include?("simon_garlow@education.gov.uk") &&
        delivery.subject == "Claim funding for mentor training: you have been added to the service"
    end

    expect(email).not_to be_nil
  end

  def when_i_click_on_simon_garlow
    click_on "Simon Garlow"
  end

  def then_i_see_simon_garlows_details_page
    expect(page).to have_title("Simon Garlow - Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Users")
    expect(page).to have_span_caption("North Star SCITT")
    expect(page).to have_h1("Simon Garlow")
    expect(page).to have_summary_list_row("Email address", "simon_garlow@education.gov.uk")
    expect(page).to have_link("Remove user")
  end

  def when_i_click_on_anne_wilson
    click_on "Anne Wilson"
  end

  def then_i_see_my_own_details_page_without_a_remove_link
    expect(page).to have_h1("Anne Wilson")
    expect(page).not_to have_link("Remove user")
  end

  def and_i_click_on_barry_garlow
    click_on "Barry Garlow"
  end

  def and_i_click_on_remove_user
    click_on "Remove user"
  end
  alias_method :when_i_click_on_remove_user, :and_i_click_on_remove_user

  def then_i_see_the_removal_confirmation_page
    expect(page).to have_title("Are you sure you want to remove this user? - Barry Garlow - Claim funding for mentor training - GOV.UK")
    expect(page).to have_span_caption("Barry Garlow")
    expect(page).to have_h1("Are you sure you want to remove this user?")
    expect(page).to have_warning_text("Barry Garlow will be sent an email to tell them you removed them from North Star SCITT.")
  end

  def then_i_see_the_users_page_without_barry_garlow
    expect(page).to have_success_banner("User removed")
    expect(page).to have_table_row("Full name" => "Anne Wilson", "Email address" => "anne_wilson@education.gov.uk")
    expect(page).not_to have_content("Barry Garlow")
  end

  def and_barry_garlow_has_been_sent_a_removal_email
    email = ActionMailer::Base.deliveries.find do |delivery|
      delivery.to.include?("barry_garlow@education.gov.uk") &&
        delivery.subject == "You have been removed from Claim funding for mentor training"
    end

    expect(email).not_to be_nil
  end

  def then_i_cannot_view_the_other_providers_users
    expect { visit claims_provider_users_path(@other_provider) }.to raise_error(ActiveRecord::RecordNotFound)
  end
end
