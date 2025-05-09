require "rails_helper"

RSpec.describe "Claims school user removes a mentor from a school", service: :claims, type: :system do
  scenario do
    given_an_eligible_school_exists_with_a_mentor
    and_i_am_signed_in
    and_i_navigate_to_mentors
    then_i_see_a_list_of_the_schools_mentors

    when_i_click_on_james_jameson
    then_i_see_the_mentor_page_for_james_jameson_with_removal_link

    when_i_click_on_remove_mentor
    then_i_see_the_removal_confirmation_page

    when_i_click_on_remove_mentor
    then_i_see_the_mentors_index_with_a_success_banner_and_no_mentors
  end

  private

  def given_an_eligible_school_exists_with_a_mentor
    @user_anne = build(:claims_user, first_name: "Anne", last_name: "Wilson", email: "anne_wilson@education.gov.uk")
    @mentor_james = build(:claims_mentor, first_name: "James", last_name: "Jameson")
    @claim_window = build(:claim_window, :current)
    @shelbyville_school = create(
      :claims_school,
      name: "Shelbyville Elementary",
      users: [@user_anne],
      eligible_claim_windows: [@claim_window],
      mentors: [@mentor_james],
    )
  end

  def and_i_am_signed_in
    sign_in_as(@user_anne)
  end

  def and_i_navigate_to_mentors
    within ".app-primary-navigation" do
      click_on "Mentors"
    end
  end

  def then_i_see_a_list_of_the_schools_mentors
    expect(page).to have_title("Mentors - Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Mentors")
    expect(page).to have_h1("Mentors")
    expect(page).to have_link("Add mentor", href: "/schools/#{@shelbyville_school.id}/mentors/new")
    expect(page).to have_table_row("Name" => "James Jameson",
                                   "Teacher reference number (TRN)" => @mentor_james.trn)
  end

  def when_i_click_on_james_jameson
    click_on "James Jameson"
  end

  def then_i_see_the_mentor_page_for_james_jameson_with_removal_link
    expect(page).to have_title("James Jameson - Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Mentors")
    expect(page).to have_h1("James Jameson")
    expect(page).to have_link("Remove mentor")
    expect(page).to have_summary_list_row("First name", "James")
    expect(page).to have_summary_list_row("Last name", "James")
    expect(page).to have_summary_list_row("Teacher reference number (TRN)", @mentor_james.trn.to_s)
  end

  def when_i_click_on_remove_mentor
    click_on "Remove mentor"
  end

  def then_i_see_the_removal_confirmation_page
    expect(page).to have_title("Are you sure you want to remove this mentor? - James Jameson - Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Mentors")
    expect(page).to have_h1("Are you sure you want to remove this mentor?")
    expect(page).to have_span_caption("James Jameson")
    expect(page).to have_button("Remove mentor")
    expect(page).to have_link("Cancel")
  end

  def then_i_see_the_mentors_index_with_a_success_banner_and_no_mentors
    expect(page).to have_title("Mentors - Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Mentors")
    expect(page).to have_h1("Mentors")
    expect(page).to have_link("Add mentor", href: "/schools/#{@shelbyville_school.id}/mentors/new")
    expect(page).to have_text("There are no mentors for Shelbyville Elementary.")
  end
end
