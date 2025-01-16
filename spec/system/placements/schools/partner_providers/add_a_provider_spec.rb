require "rails_helper"

RSpec.describe "School user adds a provider to their list of providers",
               :js, service: :placements, type: :system do
  include ActiveJob::TestHelper

  around do |example|
    perform_enqueued_jobs { example.run }
  end

  scenario do
    given_providers_exist
    and_i_am_signed_in

    when_i_am_on_the_providers_index_page
    and_i_click_on_add_provider
    then_i_see_the_add_provider_page

    when_i_click_on_continue
    then_i_see_a_validation_error_for_not_entering_a_provider_search_term

    # Shelbyville University is already in user's list of providers
    when_i_enter_shelbyville_university
    then_i_see_a_dropdown_item_for_shelbyville_university

    when_i_click_on_the_shelbyville_university_dropdown_item
    and_i_click_on_continue
    then_i_see_a_validation_error_for_shelbyville_university_is_already_in_my_list_of_providers

    # Ogdenville University has not been onboarded to the placements service
    when_i_enter_ogdenville_university
    then_i_see_a_dropdown_item_for_ogdenville_university

    when_i_click_on_the_ogdenville_university_dropdown_item
    and_i_click_on_continue
    then_i_see_the_confirm_provider_details_page_for_ogdenville_university

    when_i_click_on_confirm_and_add_provider
    then_i_see_success_message_for_ogdenville_university
    and_i_see_the_providers_index_page
    and_i_see_ogdenville_university_listed
    and_a_notification_email_is_not_sent_to_ogdenville_university

    when_i_click_on_add_provider
    and_i_enter_springfield_university
    then_i_see_a_dropdown_item_for_springfield_university

    when_i_click_on_the_springfield_university_dropdown_item
    and_i_click_on_continue
    then_i_see_the_confirm_provider_details_page_for_springfield_university

    # User reconsiders selecting a provider using back link
    when_i_click_on_back
    then_i_see_the_search_input_prefilled_with_springfield_university

    when_i_click_on_continue
    then_i_see_the_confirm_provider_details_page_for_springfield_university

    # User reconsiders selecting a provider using change link
    when_i_click_on_change
    then_i_see_the_search_input_prefilled_with_springfield_university

    when_i_click_on_continue
    then_i_see_the_confirm_provider_details_page_for_springfield_university

    when_i_click_on_confirm_and_add_provider
    then_i_see_success_message_for_springfield_university

    when_i_am_on_the_providers_index_page
    then_i_see_springfield_university_listed
    and_a_notification_email_is_sent_to_springfield_university
  end

  private

  def given_providers_exist
    @springfield_university = create(:placements_provider,
                                     name: "Springfield University",
                                     ukprn: "10101010",
                                     urn: "101010",
                                     email_addresses: ["reception@springfield.ac.uk"],
                                     telephone: "0101 010 0101",
                                     website: "http://www.springfield.ac.uk",
                                     address1: "Undisclosed")
    @springfield_university_user = create(:placements_user, providers: [@springfield_university])

    @ogdenville_university = create(:provider,
                                    name: "Ogdenville University",
                                    ukprn: "00100010",
                                    urn: "000010",
                                    email_addresses: ["reception@ogdenville.ac.uk"],
                                    telephone: "0000 000 1111",
                                    website: "http://www.ogdenville.ac.uk",
                                    address1: "1 Main Street")
    @ogdenville_university_user = create(:placements_user, providers: [@ogdenville_university])

    @shelbyville_university = create(:placements_provider, name: "Shelbyville University")

    # Pre-existing partnership between school and Shelbyville University
    @school = create(:school, :placements)
    create(:placements_partnership, school: @school, provider: @shelbyville_university)
  end

  def and_i_am_signed_in
    given_i_am_signed_in_as_a_placements_user(organisations: [@school])
  end

  def when_i_am_on_the_providers_index_page
    page.find(".app-primary-navigation__nav").click_on("Providers")

    expect(page).to have_current_path(placements_school_partner_providers_path(@school))
    expect(page).to have_title("Providers you work with - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Providers")
    expect(page).to have_h1("Providers you work with")
  end
  alias_method :and_i_see_the_providers_index_page, :when_i_am_on_the_providers_index_page

  def and_i_click_on_add_provider
    click_on "Add provider"
  end
  alias_method :when_i_click_on_add_provider, :and_i_click_on_add_provider

  def then_i_see_the_add_provider_page
    expect(primary_navigation).to have_current_item("Providers")
    expect(page).to have_title("Add a provider - Provider details - Manage school placements - GOV.UK")

    expect(page).to have_element(:span, text: "Provider details", class: "govuk-caption-l")
    expect(page).to have_element(:div, text: "Enter a provider name, United Kingdom provider number (UKPRN), unique reference number (URN) or postcode", class: "govuk-hint")
    expect(page).to have_button("Continue")
    expect(page).to have_link("Cancel", href: "/schools/#{@school.id}/partner_providers")
  end

  def and_i_enter_springfield_university
    fill_in "Add a provider", with: "Springfield University"
  end

  def then_i_see_a_dropdown_item_for_springfield_university
    expect(page).to have_css(".autocomplete__option", text: "Springfield University", wait: 10)
  end

  def when_i_click_on_the_springfield_university_dropdown_item
    page.find(".autocomplete__option", text: "Springfield University").click
  end

  def and_i_click_on_continue
    click_on "Continue"
  end
  alias_method :when_i_click_on_continue, :and_i_click_on_continue

  def then_i_see_the_confirm_provider_details_page_for_springfield_university
    expect(page).to have_title("Confirm provider details - Provider details - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Providers")

    expect(page).to have_h1("Confirm provider details")
    expect(page).to have_element(:p, text: "Adding them means you will be able to assign them to your placements. We will send them an email to let them know you have added them.", class: "govuk-body")
    expect(page).to have_h2("Provider")
    expect(page).to have_summary_list_row("Name", "Springfield University")
    expect(page).to have_summary_list_row("UK provider reference number (UKPRN)", "10101010")
    expect(page).to have_summary_list_row("Unique reference number (URN)", "101010")
    expect(page).to have_summary_list_row("Email address", "reception@springfield.ac.uk")
    expect(page).to have_summary_list_row("Telephone number", "0101 010 0101")
    expect(page).to have_summary_list_row("Address", "Undisclosed")
    expect(page).to have_button("Confirm and add provider")
    expect(page).to have_link("Cancel", href: "/schools/#{@school.id}/partner_providers")
  end

  def when_i_click_on_confirm_and_add_provider
    click_on "Confirm and add provider"
  end

  def then_i_see_springfield_university_listed
    expect(page).to have_table_row({
      "Name" => "Springfield University",
      "UK provider reference number (UKPRN)" => "10101010",
    })
  end

  def then_i_see_success_message_for_springfield_university
    expect(page).to have_success_banner("Provider added", "You can now add Springfield University to your placements.")
  end

  def springfield_university_notification
    ActionMailer::Base.deliveries.find do |delivery|
      delivery.to.include?(@springfield_university_user.email) &&
        delivery.subject == "A school has added you"
    end
  end

  def and_a_notification_email_is_sent_to_springfield_university
    email = springfield_university_notification

    expect(email).not_to be_nil
  end

  def then_i_see_a_validation_error_for_not_entering_a_provider_search_term
    expect(page).to have_validation_error("Enter a provider name, United Kingdom provider number (UKPRN), unique reference number (URN) or postcode")
  end

  def when_i_enter_shelbyville_university
    fill_in "Add a provider", with: "Shelbyville University"
  end

  def then_i_see_a_dropdown_item_for_shelbyville_university
    expect(page).to have_css(".autocomplete__option", text: "Shelbyville University", wait: 10)
  end

  def when_i_click_on_the_shelbyville_university_dropdown_item
    page.find(".autocomplete__option", text: "Shelbyville University").click
  end

  def then_i_see_a_validation_error_for_shelbyville_university_is_already_in_my_list_of_providers
    expect(page).to have_validation_error("Shelbyville University has already been added. Try another provider")
  end

  def when_i_enter_ogdenville_university
    fill_in "Add a provider", with: "Ogdenville University"
  end

  def then_i_see_a_dropdown_item_for_ogdenville_university
    expect(page).to have_css(".autocomplete__option", text: "Ogdenville University", wait: 10)
  end

  def when_i_click_on_the_ogdenville_university_dropdown_item
    page.find(".autocomplete__option", text: "Ogdenville University").click
  end

  def then_i_see_the_confirm_provider_details_page_for_ogdenville_university
    expect(page).to have_title("Confirm provider details - Provider details - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Providers")
    expect(page).to have_h1("Confirm provider details")
    expect(page).to have_element(:p, text: "Adding them means you will be able to assign them to your placements. We will send them an email to let them know you have added them.", class: "govuk-body")
    expect(page).to have_h2("Provider")
    expect(page).to have_summary_list_row("Name", "Ogdenville University")
    expect(page).to have_summary_list_row("UK provider reference number (UKPRN)", "00100010")
    expect(page).to have_summary_list_row("Unique reference number (URN)", "000010")
    expect(page).to have_summary_list_row("Email address", "reception@ogdenville.ac.uk")
    expect(page).to have_summary_list_row("Telephone number", "0000 000 1111")
    expect(page).to have_summary_list_row("Address", "1 Main Street")
    expect(page).to have_button("Confirm and add provider")
    expect(page).to have_link("Cancel", href: "/schools/#{@school.id}/partner_providers")
  end

  def and_i_see_ogdenville_university_listed
    expect(page).to have_table_row({
      "Name" => "Ogdenville University",
      "UK provider reference number (UKPRN)" => "00100010",
    })
  end

  def then_i_see_success_message_for_ogdenville_university
    expect(page).to have_success_banner("Provider added", "You can now add Ogdenville University to your placements.")
  end

  def ogdenville_university_notification
    ActionMailer::Base.deliveries.find do |delivery|
      delivery.to.include?(@ogdenville_university_user.email) &&
        delivery.subject == "A school has added you"
    end
  end

  def and_a_notification_email_is_not_sent_to_ogdenville_university
    email = ogdenville_university_notification

    expect(email).to be_nil
  end

  def when_i_click_on_back
    click_on "Back"
  end

  def then_i_see_the_search_input_prefilled_with_springfield_university
    within(".autocomplete__wrapper") do
      find_field "Add a provider", with: "Springfield University"
    end
  end

  def when_i_click_on_change
    click_on "Change"
  end
end
