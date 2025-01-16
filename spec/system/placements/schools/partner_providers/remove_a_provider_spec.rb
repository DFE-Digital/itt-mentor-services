require "rails_helper"

RSpec.describe "User removes a provider from providers list",
               service: :placements, type: :system do
  include ActiveJob::TestHelper

  around do |example|
    perform_enqueued_jobs { example.run }
  end

  scenario do
    given_providers_exist
    and_i_am_signed_in

    when_i_click_on_providers_in_the_navigation_menu
    then_i_see_the_providers_index_page

    when_i_click_on_springfield_university_in_the_providers_list
    then_i_see_the_show_page_for_springfield_university

    # User clicks cancel link
    when_i_click_on_delete_provider
    then_i_am_asked_to_confirm_delete_springfield_university

    when_i_click_on_cancel
    then_i_see_the_providers_index_page

    when_i_click_on_springfield_university_in_the_providers_list
    then_i_see_the_show_page_for_springfield_university

    when_i_click_on_delete_provider
    and_i_confirm_by_clicking_the_delete_provider_button
    then_i_see_success_message_for_removing_springfield_university
    and_i_see_that_springfield_is_no_longer_listed_on_the_provider_index_page
    and_a_notification_email_is_sent_to_springfield_university

    # Ogdenville University is not onboarded to the placements service
    when_i_click_on_ogdenville_university_in_the_providers_list
    then_i_see_the_show_page_for_ogdenville_university

    when_i_click_on_delete_provider
    and_i_confirm_by_clicking_the_delete_provider_button
    then_i_see_success_message_for_removing_ogdenville_university
    and_i_see_that_ogdenville_is_no_longer_listed_on_the_provider_index_page
    and_a_notification_email_is_not_sent_to_ogdenville_university
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

    @ogdenville_university = create(:provider, name: "Ogdenville University", ukprn: "11111")
    @ogdenville_university_user = create(:placements_user, providers: [@ogdenville_university])

    @shelbyville_university = build(:placements_provider, name: "Shelbyville University", ukprn: "22222")

    @school = build(:placements_school)
    @springfield_partnership = create(:placements_partnership, school: @school, provider: @springfield_university)
    @ogdenville_partnership = create(:placements_partnership, school: @school, provider: @ogdenville_university)
    @shelbyville_partnership = create(:placements_partnership, school: @school, provider: @shelbyville_university)
  end

  def and_i_am_signed_in
    given_i_am_signed_in_as_a_placements_user(organisations: [@school])
  end

  def when_i_click_on_providers_in_the_navigation_menu
    within ".app-primary-navigation__nav" do
      click_on "Providers"
    end
  end

  def then_i_see_the_providers_index_page
    page.find(".app-primary-navigation__nav").click_on("Providers")
    expect(primary_navigation).to have_current_item("Providers")

    expect(page).to have_title("Providers you work with - Manage school placements - GOV.UK")
    expect(page).to have_h1("Providers you work with")
  end

  def and_i_click_on_springfield_university_in_the_providers_list
    click_on "Springfield University"
  end
  alias_method :when_i_click_on_springfield_university_in_the_providers_list, :and_i_click_on_springfield_university_in_the_providers_list

  def then_i_see_the_show_page_for_springfield_university
    expect(primary_navigation).to have_current_item("Providers")
    expect(page).to have_title("Providers - Manage school placements - GOV.UK")

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
  alias_method :and_i_confirm_by_clicking_the_delete_provider_button, :when_i_click_on_delete_provider

  def then_i_am_asked_to_confirm_delete_springfield_university
    expect(primary_navigation).to have_current_item("Providers")

    expect(page).to have_title("Are you sure you want to delete this provider? - Springfield University - Manage school placements - GOV.UK")
    expect(page).to have_h1("Are you sure you want to delete this provider?")
    expect(page).to have_element(:span, text: "Springfield University", class: "govuk-caption-l")
    expect(page).to have_element(:p, text: "You will no longer be able to assign this provider to placements.")
    expect(page).to have_element(:p, text: "They will remain assigned to current placements unless you remove them.")
    expect(page).to have_warning_text("We will send an email to Springfield University to let them know they are no longer one of your providers. It is your responsibility to confirm with them whether they should still fulfil existing assigned placements.")
    expect(page).to have_button("Delete provider")
    expect(page).to have_link("Cancel", href: "/schools/#{@school.id}/partner_providers/#{@springfield_university.id}")
  end

  def when_i_click_on_cancel
    click_on "Cancel"
  end

  def then_i_see_success_message_for_removing_springfield_university
    expect(page).to have_success_banner("Provider deleted", "You can no longer assign Springfield University to your placements.")
  end

  def and_i_see_that_springfield_is_no_longer_listed_on_the_provider_index_page
    then_i_see_the_providers_index_page

    expect(page).not_to have_table_row({
      "Name" => "Springfield University",
      "UK provider reference number (UKPRN)" => "10101010",
    })

    expect(page).to have_table_row({
      "Name" => "Ogdenville University",
      "UK provider reference number (UKPRN)" => "11111",
    },
                                   {
                                     "Name" => "Shelbyville University",
                                     "UK provider reference number (UKPRN)" => "22222",
                                   })
  end

  def springfield_university_notification
    ActionMailer::Base.deliveries.find do |delivery|
      delivery.to.include?(@springfield_university_user.email) &&
        delivery.subject == "A school has removed you"
    end
  end

  def and_a_notification_email_is_sent_to_springfield_university
    email = springfield_university_notification

    expect(email).not_to be_nil
  end

  def when_i_click_on_ogdenville_university_in_the_providers_list
    click_on "Ogdenville University"
  end

  def then_i_see_the_show_page_for_ogdenville_university
    expect(primary_navigation).to have_current_item("Providers")

    expect(page).to have_h1("Ogdenville University")
    expect(page).to have_summary_list_row("UK provider reference number (UKPRN)", "11111")
    expect(page).to have_link("Delete provider", href: "/schools/#{@school.id}/partner_providers/#{@ogdenville_university.id}/remove")
  end

  def then_i_see_success_message_for_removing_ogdenville_university
    expect(page).to have_success_banner("Provider deleted", "You can no longer assign Ogdenville University to your placements.")
  end

  def and_i_see_that_ogdenville_is_no_longer_listed_on_the_provider_index_page
    then_i_see_the_providers_index_page

    expect(page).not_to have_table_row({
      "Name" => "Springfield University",
      "UK provider reference number (UKPRN)" => "10101010",
    },
                                       { "Name" => "Ogdenville University",
                                         "UK provider reference number (UKPRN)" => "11111" })

    expect(page).to have_table_row({
      "Name" => "Shelbyville University",
      "UK provider reference number (UKPRN)" => "22222",
    })
  end

  def ogdenville_university_notification
    ActionMailer::Base.deliveries.find do |delivery|
      delivery.to.include?(@ogdenville_university_user.email) &&
        delivery.subject == "A school has removed you"
    end
  end

  def and_a_notification_email_is_not_sent_to_ogdenville_university
    email = ogdenville_university_notification

    expect(email).to be_nil
  end
end
