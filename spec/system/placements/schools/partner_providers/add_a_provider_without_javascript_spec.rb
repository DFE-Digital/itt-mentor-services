require "rails_helper"

RSpec.describe "School user adds a provider to their list of providers",
               service: :placements, type: :system do
  include ActiveJob::TestHelper

  around do |example|
    perform_enqueued_jobs { example.run }
  end

  scenario do
    given_providers_exist
    and_the_school_partner_providers_flag_is_enabled
    and_i_am_signed_in

    when_i_am_on_the_providers_index_page
    and_i_see_shelbyville_university_listed
    and_i_click_on_add_provider
    then_i_see_the_add_provider_page

    when_i_click_on_continue
    then_i_see_a_validation_error_for_not_entering_a_provider_search_term

    # Shelbyville University is already in user's list of providers
    when_i_enter_shelb
    and_i_click_on_continue
    then_i_see_a_list_of_search_results_for_shelb

    when_i_choose_shelbyville_university
    and_i_click_on_continue
    then_i_see_a_validation_error_for_shelbyville_university_is_already_in_my_list_of_providers

    # Ogdenville University has not been onboarded to the placements service
    when_i_am_on_the_providers_index_page
    and_i_click_on_add_provider
    and_i_enter_ogden
    and_i_click_on_continue
    then_i_see_a_list_of_search_results_for_ogden

    when_i_choose_ogdenville_university
    and_i_click_on_continue
    then_i_see_the_confirm_provider_details_page_for_ogdenville_university

    when_i_click_on_confirm_and_add_provider
    then_i_see_success_message_for_ogdenville
    and_i_see_the_providers_index_page
    and_i_see_ogdenville_university_listed
    and_a_notification_email_is_not_sent_to_ogdenville_university

    when_i_click_on_add_provider
    and_i_enter_spring
    and_i_click_on_continue
    then_i_see_a_list_of_search_results_for_spring

    when_i_choose_springfield_university
    and_i_click_on_continue
    then_i_see_the_confirm_provider_details_page_for_springfield_university

    # User reconsiders selecting a provider using back link
    when_i_click_on_back
    then_i_see_a_list_of_search_results_for_spring
    and_the_option_for_springfield_university_is_preselected

    when_i_click_on_back
    then_i_see_the_search_input_prefilled_with_spring

    when_i_click_on_continue
    and_i_choose_springfield_university
    and_i_click_on_continue
    then_i_see_the_confirm_provider_details_page_for_springfield_university

    # User reconsiders selecting a provider using change link
    when_i_click_on_change
    then_i_see_the_search_input_prefilled_with_spring

    when_i_click_on_continue
    and_i_choose_springfield_university
    and_i_click_on_continue
    then_i_see_the_confirm_provider_details_page_for_springfield_university

    when_i_click_on_confirm_and_add_provider
    then_i_see_success_message_for_springfield_university
    and_i_see_the_providers_index_page
    and_i_see_springfield_university_listed
    and_a_notification_email_is_sent_to_springfield_university
  end

  private

  def given_providers_exist
    @springfield_email_address = build(:provider_email_address, email_address: "reception@springfield.ac.uk")
    @springfield_university = build(:placements_provider,
                                    name: "Springfield University",
                                    ukprn: "10101010",
                                    urn: "101010",
                                    telephone: "0101 010 0101",
                                    website: "http://www.springfield.ac.uk",
                                    address1: "Undisclosed",
                                    provider_email_addresses: [@springfield_email_address])
    @springfield_university_user = create(:placements_user, providers: [@springfield_university])

    @ogdenville_email_address = build(:provider_email_address, email_address: "reception@ogdenville.ac.uk")
    @ogdenville_university = build(:provider,
                                   name: "Ogdenville University",
                                   ukprn: "00100010",
                                   urn: "000010",
                                   telephone: "0000 000 1111",
                                   website: "http://www.ogdenville.ac.uk",
                                   address1: "1 Main Street",
                                   provider_email_addresses: [@ogdenville_email_address])
    @ogdenville_university_user = create(:placements_user, providers: [@ogdenville_university])

    @shelbyville_university = create(:placements_provider, name: "Shelbyville University", ukprn: "2222222")
    @shelbyville_college = create(:placements_provider, name: "Shelbyville College")
    @ogdenville_teacher_training_centre = create(:placements_provider, name: "Ogdenville Teacher Training Centre")
    @springfield_polytechnic = create(:placements_provider, name: "Springfield Polytechnic")

    # Pre-existing partnership between school and Shelbyville University
    @school = create(:school, :placements)
    create(:placements_partnership, school: @school, provider: @shelbyville_university)
  end

  def and_the_school_partner_providers_flag_is_enabled
    Flipper.add(:school_partner_providers)
    Flipper.enable(:school_partner_providers)
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
    expect(page).to have_govuk_body("Add providers to be able to assign them to your placements.")
    expect(page).to have_link("Add provider", class: "govuk-button")
  end
  alias_method :and_i_see_the_providers_index_page, :when_i_am_on_the_providers_index_page

  def and_i_click_on_add_provider
    click_on "Add provider"
  end
  alias_method :when_i_click_on_add_provider, :and_i_click_on_add_provider

  def then_i_see_the_add_provider_page
    expect(primary_navigation).to have_current_item("Providers")
    expect(page).to have_title("Add a provider - Provider details - Manage school placements - GOV.UK")

    expect(page).to have_span_caption("Provider details")
    expect(page).to have_hint(
      "Enter a provider name, United Kingdom provider number (UKPRN), unique reference number (URN) or postcode",
    )
    expect(page).to have_button("Continue")
    expect(page).to have_link("Cancel", href: "/schools/#{@school.id}/partner_providers")
  end

  def and_i_enter_spring
    fill_in "Add a provider", with: "Spring"
  end

  def then_i_see_a_list_of_search_results_for_spring
    expect(page).to have_field("Springfield University", type: :radio)
    expect(page).to have_field("Springfield Polytechnic", type: :radio)
    expect(page).not_to have_field("Springfield Grammar", type: :radio)
  end

  def and_i_choose_springfield_university
    choose "Springfield University"
  end
  alias_method :when_i_choose_springfield_university, :and_i_choose_springfield_university

  def and_i_click_on_continue
    click_on "Continue"
  end
  alias_method :when_i_click_on_continue, :and_i_click_on_continue

  def then_i_see_the_confirm_provider_details_page_for_springfield_university
    expect(page).to have_title("Confirm provider details - Provider details - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Providers")
    expect(page).to have_h1("Confirm provider details")
    expect(page).to have_govuk_body(
      "Adding them means you will be able to assign them to your placements. We will send them an email to let them know you have added them.",
    )
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

  def and_i_see_springfield_university_listed
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
    expect(page).to have_validation_error(
      "Enter a provider name, United Kingdom provider number (UKPRN), unique reference number (URN) or postcode",
    )
  end

  def when_i_enter_shelb
    fill_in "Add a provider", with: "Shelb"
  end

  def then_i_see_a_list_of_search_results_for_shelb
    expect(page).to have_field("Shelbyville University", type: :radio)
    expect(page).to have_field("Shelbyville College", type: :radio)
    expect(page).not_to have_field("Shelbyville Grammar", type: :radio)
  end

  def when_i_choose_shelbyville_university
    choose "Shelbyville University"
  end

  def then_i_see_a_validation_error_for_shelbyville_university_is_already_in_my_list_of_providers
    expect(page).to have_validation_error("Shelbyville University has already been added. Try another provider")
  end

  def and_i_enter_ogden
    fill_in "Add a provider", with: "Ogden"
  end

  def then_i_see_a_list_of_search_results_for_ogden
    expect(page).to have_field("Ogdenville University", type: :radio)
    expect(page).to have_field("Ogdenville Teacher Training Centre", type: :radio)
    expect(page).not_to have_field("Ogdenville Grammar", type: :radio)
  end

  def when_i_choose_ogdenville_university
    choose "Ogdenville University"
  end

  def then_i_see_the_confirm_provider_details_page_for_ogdenville_university
    expect(page).to have_title("Confirm provider details - Provider details - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Providers")
    expect(page).to have_h1("Confirm provider details")
    expect(page).to have_govuk_body(
      "Adding them means you will be able to assign them to your placements. We will send them an email to let them know you have added them.",
    )
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

  def and_i_see_shelbyville_university_listed
    expect(page).to have_table_row({
      "Name" => "Shelbyville University",
      "UK provider reference number (UKPRN)" => "2222222",
    })
  end

  def then_i_see_success_message_for_ogdenville
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

  def and_i_click_on_back
    click_on "Back"
  end

  def and_the_option_for_springfield_university_is_preselected
    expect(page).to have_checked_field("Springfield University")
  end

  def then_i_see_the_search_input_prefilled_with_spring
    find_field "Add a provider", with: "Spring"
  end

  def when_i_click_on_change
    click_on "Change Name"
  end
end
