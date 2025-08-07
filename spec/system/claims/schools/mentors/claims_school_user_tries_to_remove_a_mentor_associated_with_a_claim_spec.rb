require "rails_helper"

RSpec.describe "Claims school user tries to remove a mentor associated with a claim", service: :claims, type: :system do
  scenario do
    given_an_eligible_school_exists_with_a_mentor_with_a_draft_claim_and_a_mentor_with_a_submitted_claim
    and_i_am_signed_in

    when_i_navigate_to_mentors
    then_i_see_a_list_of_the_schools_mentors

    when_i_click_on_james_jameson
    then_i_see_the_mentor_page_for_james_jameson_with_removal_link

    when_i_click_on_remove_mentor
    then_i_see_a_page_notifying_me_that_i_cannot_remove_james_jameson_as_he_is_included_in_an_active_claim

    when_i_navigate_to_mentors
    then_i_see_a_list_of_the_schools_mentors

    when_i_click_on_barry_garlow
    then_i_see_the_mentor_page_for_barry_garlow_with_removal_link

    when_i_click_on_remove_mentor
    then_i_see_a_page_notifying_me_that_i_cannot_remove_barry_garlow_as_he_is_included_in_an_active_claim
  end

  private

  def given_an_eligible_school_exists_with_a_mentor_with_a_draft_claim_and_a_mentor_with_a_submitted_claim
    @user_anne = build(:claims_user, first_name: "Anne", last_name: "Wilson", email: "anne_wilson@education.gov.uk")
    @mentor_james = build(:claims_mentor, first_name: "James", last_name: "Jameson")
    @mentor_barry = build(:claims_mentor, first_name: "Barry", last_name: "Garlow")
    @provider = build(:claims_provider, :best_practice_network)
    @claim_window = build(:claim_window, :current)
    @date_completed = @claim_window.starts_on + 1.day
    @shelbyville_school = build(
      :claims_school,
      name: "Shelbyville Elementary",
      users: [@user_anne],
      eligible_claim_windows: [@claim_window],
      mentors: [@mentor_james, @mentor_barry],
    )
    @draft_claim = build(:claim,
                         :draft,
                         school: @shelbyville_school,
                         reference: "88888888",
                         provider: @provider,
                         claim_window: @claim_window)
    @draft_mentor_training = create(:mentor_training,
                                    claim: @draft_claim,
                                    mentor: @mentor_barry,
                                    hours_completed: 8,
                                    provider: @provider,
                                    date_completed: @date_completed)
    @submitted_claim = build(:claim,
                             :submitted,
                             school: @shelbyville_school,
                             reference: "12345678",
                             submitted_at: @date_completed,
                             provider: @provider,
                             submitted_by: @user_anne,
                             claim_window: @claim_window)
    @submitted_mentor_training = create(:mentor_training,
                                        claim: @submitted_claim,
                                        mentor: @mentor_james,
                                        hours_completed: 20,
                                        date_completed: @date_completed,
                                        provider: @provider)
  end

  def and_i_am_signed_in
    sign_in_as(@user_anne)
  end

  def when_i_navigate_to_mentors
    within primary_navigation do
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
    expect(page).to have_table_row("Name" => "Barry Garlow",
                                   "Teacher reference number (TRN)" => @mentor_barry.trn)
  end

  def when_i_click_on_james_jameson
    click_on "James Jameson"
  end

  def when_i_click_on_barry_garlow
    click_on "Barry Garlow"
  end

  def then_i_see_the_mentor_page_for_james_jameson_with_removal_link
    expect(page).to have_title("James Jameson - Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Mentors")
    expect(page).to have_h1("James Jameson")
    expect(page).to have_link("Remove mentor")
    expect(page).to have_summary_list_row("First name", "James")
    expect(page).to have_summary_list_row("Last name", "Jameson")
    expect(page).to have_summary_list_row("Teacher reference number (TRN)", @mentor_james.trn.to_s)
  end

  def then_i_see_the_mentor_page_for_barry_garlow_with_removal_link
    expect(page).to have_title("Barry Garlow - Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Mentors")
    expect(page).to have_h1("Barry Garlow")
    expect(page).to have_link("Remove mentor")
    expect(page).to have_summary_list_row("First name", "Barry")
    expect(page).to have_summary_list_row("Last name", "Garlow")
    expect(page).to have_summary_list_row("Teacher reference number (TRN)", @mentor_barry.trn.to_s)
  end

  def when_i_click_on_remove_mentor
    click_on "Remove mentor"
  end

  def then_i_see_a_page_notifying_me_that_i_cannot_remove_james_jameson_as_he_is_included_in_an_active_claim
    expect(page).to have_title("You cannot remove this mentor - Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Mentors")
    expect(page).to have_h1("You cannot remove this mentor")
    expect(page).to have_span_caption("James Jameson")
    expect(page).to have_text("You cannot remove this mentor because they are included in an active claim.")
    expect(page).not_to have_button("Remove mentor")
    expect(page).to have_link("Cancel")
  end

  def then_i_see_a_page_notifying_me_that_i_cannot_remove_barry_garlow_as_he_is_included_in_an_active_claim
    expect(page).to have_title("You cannot remove this mentor - Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Mentors")
    expect(page).to have_h1("You cannot remove this mentor")
    expect(page).to have_span_caption("Barry Garlow")
    expect(page).to have_text("You cannot remove this mentor because they are included in an active claim.")
    expect(page).not_to have_button("Remove mentor")
    expect(page).to have_link("Cancel")
  end
end
