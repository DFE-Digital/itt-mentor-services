require "rails_helper"

RSpec.describe "Placements / Schools / Partner providers / Remove a partner provider",
               service: :placements, type: :system do
  include ActiveJob::TestHelper

  around do |example|
    perform_enqueued_jobs { example.run }
  end

  scenario "User removes a provider" do
    given_providers_exist
    and_i_am_signed_in

    when_i_am_on_the_providers_index_page
    and_i_click_on_springfield_university_in_the_providers_list
    then_i_see_the_show_page_for_springfield_university

    when_i_click_on_delete_provider
    and_i_am_asked_to_confirm_delete_springfield_university
    # and_i_click_on_cancel
    # then_i_see_the_provider_index_page

    # when_i_click_on_springfield_university_in_the_providers_list
    # then_i_see_the_show_page_for_springfield_university

    # when_i_click_on_delete_provider
    # then_i_see_success_message_for_removing_springfield_university
    # and_i_see_that_springfield_is_no_longer_listed_on_the_provider_index_page
    # and_ogdenville_university_remains_in_the_list
    # and_a_notification_email_is_sent_to_springfield_university

    # given_ogdenville_university_is_not_onboarded_on_to_the_placements_service
    # when_i_click_on_ogdenville_university_in_the_providers_list
    # then_i_see_the_show_page_for_ogdenville_university

    # when_i_click_on_delete_provider
    # then_i_am_asked_to_confirm_delete_provider

    # when_i_click_on_delete_provider
    # then_i_see_success_message_for_removing_ogdenville_university
    # and_i_see_that_ogdenville_is_no_longer_listed_on_the_provider_index_page
    # and_shelbyville_university_remains_in_the_list
    # and_a_notification_email_is_not_sent_to_ogdenville_university
  end

  private

  def given_providers_exist
    @school = create(:placements_school)
    @springfield_university = create(:placements_provider,
                                     name: "Springfield University",
                                     ukprn: "10101010",
                                     urn: "101010",
                                     email_address: "reception@springfield.ac.uk",
                                     telephone: "0101 010 0101",
                                     website: "http://www.springfield.ac.uk",
                                     address1: "Undisclosed")
    @springfield_university_user = create(:placements_user, providers: [@springfield_university])

    @ogdenville_university = create(:placements_provider, name: "Ogdenville University")
    @ogdenville_university_user = create(:placements_user, providers: [@ogdenville_university])

    @shelbyville_university = create(:placements_provider, name: "Shelbyville University")

    @springfield_partnership = create(:placements_partnership, school: @school, provider: @springfield_university)
    @ogdenville_partnership = create(:placements_partnership, school: @school, provider: @ogdenville_university)
    @shelbyville_partnership = create(:placements_partnership, school: @school, provider: @shelbyville_university)
  end

  def and_i_am_signed_in
    given_i_am_signed_in_as_a_placements_user(organisations: [@school])
  end

  def when_i_am_on_the_providers_index_page
    page.find(".app-primary-navigation__nav").click_on("Providers")
    expect(primary_navigation).to have_current_item("Providers")

    expect(page).to have_title("Providers you work with - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Providers")
    expect(page).to have_h1("Providers you work with")
  end

  def and_i_click_on_springfield_university_in_the_providers_list
    click_on "Springfield University"
  end

  def then_i_see_the_show_page_for_springfield_university
    expect(page).to have_current_path(placements_school_partner_provider_path(@school, @springfield_university))
    expect(primary_navigation).to have_current_item("Providers")

    expect(page).to have_h1("Springfield University")
    expect(page).to have_summary_list_row("UK provider reference number (UKPRN)", "10101010")
    expect(page).to have_summary_list_row("Unique reference number (URN)", "101010")
    expect(page).to have_summary_list_row("Email address", "reception@springfield.ac.uk")
    expect(page).to have_summary_list_row("Telephone number", "0101 010 0101")
    expect(page).to have_summary_list_row("Website", "http://www.springfield.ac.uk")
    expect(page).to have_summary_list_row("Address", "Undisclosed")
    expect(page).to have_link("Delete provider", href: "/schools/#{@school.id}/partner_providers/#{@springfield_university.id}/remove")
  end

  def when_i_click_on_delete_provider
    click_on "Delete provider"
  end

  def and_i_am_asked_to_confirm_delete_springfield_university
    expect(primary_navigation).to have_current_item("Providers")

    expect(page).to have_title("Are you sure you want to delete this provider?")
    expect(page).to have_warning_text("We will send an email to Springfield University to let them know they are no longer one of your providers. It is your responsibility to confirm with them whether they should still fulfil existing assigned placements.")
  end
end
