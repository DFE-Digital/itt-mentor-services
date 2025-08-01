require "rails_helper"

RSpec.describe "Claims school user views a schools mentor list", service: :claims, type: :system do
  scenario do
    given_an_eligible_school_exists_with_mentors
    and_i_am_signed_in
    and_i_navigate_to_mentors
    then_i_see_a_list_of_the_schools_mentors
    and_i_dont_see_any_mentors_not_associated_with_the_school
  end

  private

  def given_an_eligible_school_exists_with_mentors
    @user_anne = build(:claims_user, first_name: "Anne", last_name: "Wilson", email: "anne_wilson@education.gov.uk")
    @mentor_james =  build(:claims_mentor, first_name: "James", last_name: "Jameson")
    @mentor_barry =  build(:claims_mentor, first_name: "Barry", last_name: "Garlow")
    @mentor_sam = build(:claims_mentor, first_name: "Sam", last_name: "Pete")
    @claim_window = build(:claim_window, :current)
    @shelbyville_school = create(
      :claims_school,
      name: "Shelbyville Elementary",
      users: [@user_anne],
      eligible_claim_windows: [@claim_window],
      mentors: [@mentor_james, @mentor_barry],
    )
  end

  def and_i_am_signed_in
    sign_in_as(@user_anne)
  end

  def and_i_navigate_to_mentors
    within primary_navigation do
      click_on "Mentors"
    end
  end

  def then_i_see_a_list_of_the_schools_mentors
    expect(page).to have_title("Mentors - Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Mentors")
    expect(page).to have_h1("Mentors")
    expect(page).to have_link("Add mentor", href: "/schools/#{@shelbyville_school.id}/mentors/new")
    expect(page).to have_table_row("Name" => "Barry Garlow",
                                   "Teacher reference number (TRN)" => @mentor_barry.trn)
    expect(page).to have_table_row("Name" => "James Jameson",
                                   "Teacher reference number (TRN)" => @mentor_james.trn)
  end

  def and_i_dont_see_any_mentors_not_associated_with_the_school
    expect(page).not_to have_table_row("Name" => "Sam Pete",
                                       "Teacher reference number (TRN)" => @mentor_sam.trn)
  end
end
