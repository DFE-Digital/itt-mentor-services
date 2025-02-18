require "rails_helper"

RSpec.describe "Support user uses the email address of an existing user", service: :placements, type: :system do
  scenario do
    given_that_providers_exist
    and_a_user_exists_for_the_best_practice_network_provider
    and_i_am_signed_in
    when_i_click_on_best_practice_network
    and_i_click_users_in_the_primary_navigation
    then_i_see_the_users_index_page_for_best_practice_network_provider
    and_i_see_user_susan_storm

    when_i_click_on_add_user
    then_i_see_the_form_to_enter_the_users_details

    when_i_enter_the_users_details
    and_i_click_on_continue
    then_i_see_an_error_related_to_the_users_email_address
  end

  private

  def given_that_providers_exist
    @niot_provider = create(:placements_provider, :niot)
    @bpn_provider = create(:placements_provider, :best_practice_network)
  end

  def and_a_user_exists_for_the_best_practice_network_provider
    create(:placements_user,
           first_name: "Sue",
           last_name: "Storm",
           email: "susan_storm@example.com",
           providers: [@bpn_provider])
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

  def then_i_see_the_users_index_page_for_best_practice_network_provider
    expect(page).to have_title("Users - Manage school placements - GOV.UK")
    expect(page).to have_h1("Users")
    expect(page).to have_element(:span, text: "Best Practice Network")
    expect(page).to have_current_path(placements_provider_users_path(@bpn_provider))
  end

  def when_i_click_on_add_user
    click_on "Add user"
  end

  def then_i_see_the_form_to_enter_the_users_details
    expect(page).to have_title(
      "Personal details - User details - Manage school placements - GOV.UK",
    )
    expect(page).to have_h1("Personal details")
    expect(page).to have_element(:span, text: "User details", class: "govuk-caption-l")
  end

  def when_i_enter_the_users_details
    fill_in "First name", with: "Susan"
    fill_in "Last name", with: "Storm"
    fill_in "Email address", with: "susan_storm@example.com"
  end

  def and_i_click_on_continue
    click_on "Continue"
  end

  def then_i_see_an_error_related_to_the_users_email_address
    expect(page).to have_validation_error(
      "Email address already in use",
    )
  end

  def and_i_see_user_susan_storm
    expect(page).to have_table_row({
      "Name" => "Sue Storm",
      "Email address" => "susan_storm@example.com",
    })
  end
end
