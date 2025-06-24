require "rails_helper"

RSpec.describe "Support user removes partner schools",
               service: :placements, type: :system do
  include ActiveJob::TestHelper

  scenario do
    given_a_provider_exists_with_two_partner_schools
    and_placements_exist_with_shelbyville_elementary
    given_i_am_signed_in_as_a_placements_support_user

    when_i_click_on_westbrook_provider
    then_i_see_the_find_page

    when_i_navigate_to_the_provider_schools_page
    then_i_see_the_provider_schools_index_with_two_schools

    when_i_click_on_springfield_school
    then_i_see_the_springfield_school_show_page

    when_i_click_on_delete_school
    then_i_see_the_confirm_school_partnership_deletion_page_for_springfield_school

    when_i_click_on_cancel
    then_i_see_the_springfield_school_show_page

    when_i_click_on_delete_school
    then_i_see_the_confirm_school_partnership_deletion_page_for_springfield_school

    when_i_click_on_delete_school
    then_i_return_to_the_provider_schools_index_page_with_one_school
    and_i_see_a_success_message_for_the_deletion_of_springfield_school
    and_springfield_school_is_removed_from_the_partner_schools_list

    when_i_click_on_shelbyville_elementary
    then_i_see_the_shelbyville_elementary_show_page

    when_i_click_on_delete_school
    then_i_see_the_confirm_school_partnership_deletion_page_for_shelbyville_elementary
    and_i_see_a_list_of_associated_placements_with_shelbyville_elementary_and_provider

    when_i_click_on_delete_school
    then_i_return_to_the_provider_schools_index_page_with_no_schools
    and_i_see_a_success_message_for_the_deletion_of_shelbyville_elementary
  end

  private

  def given_a_provider_exists_with_two_partner_schools
    @user_anne = build(:placements_user, first_name: "Anne", last_name: "Wilson", email: "anne_wilson@education.gov.uk")
    @provider = build(:placements_provider, name: "Westbrook Provider", users: [@user_anne])
    @springfield_school = build(
      :placements_school,
      name: "Springfield School",
      urn: "12345",
      email_address: "www.springfield_school@sample.com",
      ukprn: "54322",
      address1: "44 Baddle Way",
      website: "www.springfield_school.com",
      telephone: "02083335555",
    )
    @shelbyville_elementary = build(
      :placements_school,
      name: "Shelbyville Elementary",
      urn: "54321",
      email_address: "www.shelbyville_elementary@sample.com",
      ukprn: "55555",
      address1: "44 Langton Way",
      website: "www.shelbyville_elementary.com",
      telephone: "02083334444",
    )
    @shelbyville_partnership = create(:placements_partnership, provider: @provider, school: @shelbyville_elementary)
    @springfield_partnership = create(:placements_partnership, provider: @provider, school: @springfield_school)
  end

  def and_placements_exist_with_shelbyville_elementary
    @english = build(:subject, name: "English")
    @maths = build(:subject, name: "Mathematics")
    @science = build(:subject, name: "Science")

    @english_placement = create(:placement, school: @shelbyville_elementary, provider: @provider, subject: @english)
    @maths_placement = create(:placement, school: @shelbyville_elementary, provider: @provider, subject: @maths)
    @science_placement = create(:placement, school: @shelbyville_elementary, provider: @provider, subject: @science)
  end

  def when_i_click_on_westbrook_provider
    click_on "Westbrook Provider"
  end

  def then_i_see_the_find_page
    expect(page).to have_title("Find schools hosting placements - Manage school placements - GOV.UK")
    expect(page).to have_element(:span, text: "Westbrook Provider", class: "govuk-heading-s")
    expect(primary_navigation).to have_current_item("Find")
    expect(page).to have_h1("Find schools hosting placements")
  end

  def when_i_navigate_to_the_provider_schools_page
    within(primary_navigation) do
      click_on "Schools"
    end
  end

  def then_i_see_the_provider_schools_index_with_two_schools
    expect(page).to have_title("Schools you work with - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Schools")
    expect(page).to have_h1("Schools you work with")
    expect(page).to have_paragraph("View all placements your schools have published.")
    expect(page).to have_link("Add school", href: new_add_partner_school_placements_provider_partner_schools_path(@provider))
    expect(page).to have_table_row({ "Name": "Shelbyville Elementary",
                                     "Unique reference number (URN)": "54321" })
    expect(page).to have_table_row({ "Name": "Springfield School",
                                     "Unique reference number (URN)": "12345" })
  end

  def when_i_click_on_springfield_school
    click_on "Springfield School"
  end

  def then_i_see_the_springfield_school_show_page
    expect(page).to have_title("Partner schools - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Schools")
    expect(page).to have_link("Back")
    expect(page).to have_h1("Springfield School")
    expect(page).to have_summary_list_row("Name", "Springfield School")
    expect(page).to have_summary_list_row("UK provider reference number (UKPRN)", "54322")
    expect(page).to have_summary_list_row("Unique reference number (URN)", "12345")
    expect(page).to have_summary_list_row("Email address", "www.springfield_school@sample.com")
    expect(page).to have_summary_list_row("Telephone number", "02083335555")
    expect(page).to have_summary_list_row("Website", "http://www.springfield_school.com")
    expect(page).to have_summary_list_row("Address", "44 Baddle Way")
    expect(page).to have_h2("Additional details")
    expect(page).to have_h2("Special educational needs and disabilities (SEND)")
    expect(page).to have_h2("Ofsted")
    expect(page).to have_link("Delete school", href: remove_placements_provider_partner_school_path(@provider, @springfield_school))
  end

  def when_i_click_on_delete_school
    click_on "Delete school"
  end

  def then_i_see_the_confirm_school_partnership_deletion_page_for_springfield_school
    expect(page).to have_title("Are you sure you want to delete this partner school? - Springfield School - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Schools")
    expect(page).to have_link("Back")
    expect(page).to have_h1("Are you sure you want to delete this school?")
    expect(page).to have_paragraph("The school will no longer be able to assign you to their placements. You can still view placements at this school.")
    expect(page).to have_paragraph("You will remain assigned to current placements unless the school removes you.")
    expect(page).to have_warning_text("We will send an email to Springfield School. This will let them know they can no longer assign you to placements.")
    expect(page).to have_button("Delete school")
    expect(page).to have_link("Cancel", href: placements_provider_partner_school_path(@provider, @springfield_school))
  end

  def when_i_click_on_cancel
    click_on "Cancel"
  end

  def then_i_return_to_the_provider_schools_index_page_with_one_school
    expect(page).to have_title("Schools you work with - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Schools")
    expect(page).to have_h1("Schools you work with")
    expect(page).to have_paragraph("View all placements your schools have published.")
    expect(page).to have_link("Add school", href: new_add_partner_school_placements_provider_partner_schools_path(@provider))
    expect(page).to have_table_row({ "Name": "Shelbyville Elementary",
                                     "Unique reference number (URN)": "54321" })
  end

  def and_i_see_a_success_message_for_the_deletion_of_springfield_school
    expect(page).to have_success_banner("School deleted", "Springfield School can no longer assign you to their placements.")
  end

  def and_springfield_school_is_removed_from_the_partner_schools_list
    expect(page).not_to have_table_row({ "Name": "Springfield School",
                                         "Unique reference number (URN)": "12345" })
  end

  def when_i_click_on_shelbyville_elementary
    click_on "Shelbyville Elementary"
  end

  def then_i_see_the_shelbyville_elementary_show_page
    expect(page).to have_title("Partner schools - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Schools")
    expect(page).to have_link("Back")
    expect(page).to have_h1("Shelbyville Elementary")
    expect(page).to have_summary_list_row("Name", "Shelbyville Elementary")
    expect(page).to have_summary_list_row("UK provider reference number (UKPRN)", "55555")
    expect(page).to have_summary_list_row("Unique reference number (URN)", "54321")
    expect(page).to have_summary_list_row("Email address", "www.shelbyville_elementary@sample.com")
    expect(page).to have_summary_list_row("Telephone number", "02083334444")
    expect(page).to have_summary_list_row("Website", "http://www.shelbyville_elementary.com")
    expect(page).to have_summary_list_row("Address", "44 Langton Way")
    expect(page).to have_h2("Additional details")
    expect(page).to have_h2("Special educational needs and disabilities (SEND)")
    expect(page).to have_h2("Ofsted")
    expect(page).to have_link("Delete school", href: remove_placements_provider_partner_school_path(@provider, @shelbyville_elementary))
  end

  def then_i_see_the_confirm_school_partnership_deletion_page_for_shelbyville_elementary
    expect(page).to have_title("Are you sure you want to delete this partner school? - Shelbyville Elementary - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Schools")
    expect(page).to have_link("Back")
    expect(page).to have_h1("Are you sure you want to delete this school?")
    expect(page).to have_paragraph("The school will no longer be able to assign you to their placements. You can still view placements at this school.")
    expect(page).to have_paragraph("You will remain assigned to current placements unless the school removes you.")
    expect(page).to have_warning_text("We will send an email to Shelbyville Elementary. This will let them know they can no longer assign you to placements.")
    expect(page).to have_button("Delete school")
    expect(page).to have_link("Cancel", href: placements_provider_partner_school_path(@provider, @shelbyville_elementary))
  end

  def and_i_see_a_list_of_associated_placements_with_shelbyville_elementary_and_provider
    expect(page).to have_paragraph("You are currently assigned to:")
    expect(page).to have_link("English (opens in new tab)", href: placements_provider_placement_path(@provider, @english_placement))
    expect(page).to have_link("Mathematics (opens in new tab)", href: placements_provider_placement_path(@provider, @maths_placement))
    expect(page).to have_link("Science (opens in new tab)", href: placements_provider_placement_path(@provider, @science_placement))
  end

  def then_i_return_to_the_provider_schools_index_page_with_no_schools
    expect(page).to have_title("Schools you work with - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Schools")
    expect(page).to have_h1("Schools you work with")
    expect(page).to have_paragraph("View all placements your schools have published.")
    expect(page).to have_link("Add school", href: new_add_partner_school_placements_provider_partner_schools_path(@provider))
    expect(page).to have_paragraph("There are no partner schools for Westbrook Provider")
  end

  def when_i_navigate_to_the_provider_schools_page
    within(primary_navigation) do
      click_on "Schools"
    end
  end

  def then_i_see_the_provider_schools_index_with_no_schools
    expect(page).to have_title("Schools you work with - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Schools")
    expect(page).to have_h1("Schools you work with")
    expect(page).to have_paragraph("View all placements your schools have published.")
    expect(page).to have_link("Add school", href: new_add_partner_school_placements_provider_partner_schools_path(@provider))
    expect(page).to have_paragraph("There are no partner schools for Westbrook Provider")
  end

  def and_i_see_a_success_message_for_the_deletion_of_shelbyville_elementary
    expect(page).to have_success_banner("School deleted", "Shelbyville Elementary can no longer assign you to their placements.")
  end

  def when_i_click_on_back
    click_on "Back"
  end

  def when_i_click_on_continue
    click_on "Continue"
  end
  alias_method :and_i_click_on_continue, :when_i_click_on_continue
end
