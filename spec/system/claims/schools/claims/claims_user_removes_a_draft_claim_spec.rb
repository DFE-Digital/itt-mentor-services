require "rails_helper"

RSpec.describe "Claims user removes a draft claim", service: :claims, type: :system do
  scenario do
    given_an_eligible_school_exists_with_a_draft_claim
    and_i_am_signed_in
    then_i_see_the_claims_index_page_with_a_draft_claim

    when_i_click_on_the_claim_reference
    then_i_see_the_claim_show_page_with_draft_details

    when_i_click_on_remove_claim
    then_i_see_the_remove_claim_confirmation_page

    when_i_click_on_the_remove_claim_button
    then_i_see_the_claims_index_page_with_no_draft_claims_and_a_success_banner
  end

  private

  def given_an_eligible_school_exists_with_a_draft_claim
    @user_anne = build(:claims_user, first_name: "Anne", last_name: "Wilson", email: "anne_wilson@education.gov.uk")
    @mentor =  build(:claims_mentor, first_name: "James", last_name: "Jameson")
    @provider = build(:claims_provider, :best_practice_network)
    @claim_window = build(:claim_window, :current)
    @date_completed = @claim_window.starts_on + 1.day
    @shelbyville_school = build(
      :claims_school,
      name: "Shelbyville Elementary",
      users: [@user_anne],
      eligible_claim_windows: [@claim_window],
      mentors: [@mentor],
    )
    @draft_claim = build(:claim,
                         :draft,
                         school: @shelbyville_school,
                         reference: "88888888",
                         provider: @provider,
                         claim_window: @claim_window)
    @draft_mentor_training = create(:mentor_training,
                                    claim: @draft_claim,
                                    mentor: @mentor,
                                    hours_completed: 8,
                                    provider: @provider,
                                    date_completed: @date_completed)
  end

  def and_i_am_signed_in
    sign_in_as(@user_anne)
  end

  def then_i_see_the_claims_index_page_with_a_draft_claim
    expect(page).to have_title("Claims - Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Claims")
    expect(page).to have_h1("Claims")
    expect(page).to have_link("Add claim", href: "/schools/#{@shelbyville_school.id}/claims/new")
    expect(page).to have_table_row({
      "Reference" => "88888888",
      "Accredited provider" => "Best Practice Network",
      "Mentors" => "James Jameson",
      "Amount" => "£#{@shelbyville_school.region.funding_available_per_hour * 8}",
      "Date submitted" => "-",
      "Status" => "Draft",
    })
  end

  def when_i_click_on_the_claim_reference
    click_on "88888888"
  end

  def then_i_see_the_claim_show_page_with_draft_details
    expect(page).to have_link("Accept and submit", href: "/schools/#{@shelbyville_school.id}/claims/#{@draft_claim.id}/edit?step=declaration")
    expect(page).to have_title("Claim - 88888888 - Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Claims")
    expect(page).to have_h1("Claim - 88888888")
    expect(page).to have_h2("Details")
    expect(page).to have_summary_list_row("School", "Shelbyville Elementary")
    expect(page).to have_summary_list_row("Academic year", @claim_window.academic_year.name.to_s)
    expect(page).to have_summary_list_row("Accredited provider", "Best Practice Network")
    expect(page).to have_summary_list_row("Mentors", "James Jameson")

    expect(page).to have_h2("Hours of training")
    expect(page).to have_summary_list_row("James Jameson", "8 hours")

    expect(page).to have_h2("Grant funding")
    expect(page).to have_summary_list_row("Total hours", "8 hours")
    expect(page).to have_summary_list_row("Hourly rate", "£#{@shelbyville_school.region.funding_available_per_hour}")
    expect(page).to have_summary_list_row("Claim amount", "£#{@shelbyville_school.region.funding_available_per_hour * 8}")

    expect(page).to have_link("Remove claim")
  end

  def when_i_click_on_remove_claim
    click_on "Remove claim"
  end

  def then_i_see_the_remove_claim_confirmation_page
    expect(page).to have_title("Are you sure you want to remove this claim? - Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Claims")
    expect(page).to have_h1("Are you sure you want to remove this claim?")

    expect(page).to have_button("Remove claim")
    expect(page).to have_link("Cancel")
  end

  def when_i_click_on_the_remove_claim_button
    click_button "Remove claim"
  end

  def then_i_see_the_claim_removal_success_page
    expect(page).to have_title("Claims - Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Claims")
    expect(page).to have_h1("Claims")

    expect(page).to have_button("Remove claim")
    expect(page).to have_link("Cancel")
  end

  def then_i_see_the_claims_index_page_with_no_draft_claims_and_a_success_banner
    expect(page).to have_title("Claims - Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Claims")
    expect(page).to have_h1("Claims")
    expect(page).to have_link("Add claim", href: "/schools/#{@shelbyville_school.id}/claims/new")
    expect(page).to have_text("There are no claims for Shelbyville Elementary.")
    expect(page).not_to have_table_row({
      "Reference" => "88888888",
      "Accredited provider" => "Best Practice Network",
      "Mentors" => "James Jameson",
      "Amount" => "£#{@shelbyville_school.region.funding_available_per_hour * 8}",
      "Date submitted" => "-",
      "Status" => "Draft",
    })
    expect(page).to have_success_banner("Claim has been removed")
  end
end
