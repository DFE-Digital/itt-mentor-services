require "rails_helper"

RSpec.describe "Claims user views and submits claim", service: :claims, type: :system do
  scenario do
    given_an_eligible_school_exists_with_a_submitted_claim_and_a_draft_claim
    and_i_am_signed_in
    then_i_see_the_claims_index_page_with_a_submitted_claim_and_a_draft_claim

    when_i_click_on_the_claim_reference
    then_i_see_the_claim_show_page_with_submitted_details
    and_i_cant_see_submit_claim_link

    when_i_navigate_back_to_the_claims_index_page
    then_i_see_the_claims_index_page_with_a_submitted_claim_and_a_draft_claim

    when_i_click_on_the_draft_claim_reference
    then_i_see_the_claim_show_page_with_draft_details_and_a_submit_claim_link

    when_i_click_on_accept_and_submit
    then_i_see_the_claim_declaration_page

    when_i_click_on_accept_and_submit
    then_i_see_the_claim_submitted_page

    when_i_navigate_back_to_the_claims_index_page
    then_i_see_the_claims_index_page_with_two_submitted_claims
  end

  private

  def given_an_eligible_school_exists_with_a_submitted_claim_and_a_draft_claim
    @user_anne = build(:claims_user, first_name: "Anne", last_name: "Wilson", email: "anne_wilson@education.gov.uk")
    @mentor =  build(:claims_mentor, first_name: "James", last_name: "Jameson")
    @provider = build(:claims_provider, :best_practice_network) do |provider|
      provider.provider_email_addresses.build(email_address: "best_practice_network@example.com", primary: true)
    end
    @claim_window = build(:claim_window, :current)
    @date_completed = @claim_window.starts_on + 1.day
    @shelbyville_school = build(
      :claims_school,
      name: "Shelbyville Elementary",
      users: [@user_anne],
      eligible_claim_windows: [@claim_window],
      mentors: [@mentor],
    )
    @submitted_claim = create(:claim,
                              :submitted,
                              school: @shelbyville_school,
                              reference: "12345678",
                              submitted_at: @date_completed,
                              provider: @provider,
                              submitted_by: @user_anne,
                              claim_window: @claim_window)
    @draft_claim = create(:claim,
                          :draft,
                          school: @shelbyville_school,
                          reference: "88888888",
                          provider: @provider,
                          claim_window: @claim_window)
    @mentor_training = create(:mentor_training,
                              claim: @submitted_claim,
                              mentor: @mentor,
                              hours_completed: 6,
                              provider: @provider,
                              date_completed: @date_completed)
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

  def then_i_see_the_claims_index_page_with_a_submitted_claim_and_a_draft_claim
    expect(page).to have_title("Claims - Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Claims")
    expect(page).to have_h1("Claims")
    expect(page).to have_link("Add claim", href: "/schools/#{@shelbyville_school.id}/claims/new")
    expect(page).to have_table_row({
      "Reference" => "12345678",
      "Accredited provider" => "Best Practice Network",
      "Mentors" => "James Jameson",
      "Amount" => "£#{@shelbyville_school.region.funding_available_per_hour * 6}",
      "Date submitted" => @date_completed.strftime("%-d %B %Y").to_s,
      "Status" => "Submitted",
    })
    expect(page).to have_table_row({
      "Reference" => "88888888",
      "Accredited provider" => "Best Practice Network",
      "Mentors" => "James Jameson",
      "Amount" => "£#{@shelbyville_school.region.funding_available_per_hour * 8}",
      "Date submitted" => "-",
      "Status" => "Draft",
    })
  end

  def and_i_cant_see_submit_claim_link
    expect(page).not_to have_link("Submit claim")
  end

  def when_i_click_on_the_claim_reference
    click_on "12345678"
  end

  def when_i_navigate_back_to_the_claims_index_page
    within primary_navigation do
      click_on "Claims"
    end
  end

  def when_i_click_on_the_draft_claim_reference
    click_on "88888888"
  end

  def then_i_see_the_claim_show_page_with_submitted_details
    expect(page).to have_title("Claim - 12345678 - Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Claims")
    expect(page).to have_h1("Claim - 12345678")
    expect(page).to have_text("Submitted by Anne Wilson on #{@date_completed.strftime("%-d %B %Y")}.")
    expect(page).to have_h2("Details")
    expect(page).to have_summary_list_row("School", "Shelbyville Elementary")
    expect(page).to have_summary_list_row("Academic year", @claim_window.academic_year.name.to_s)
    expect(page).to have_summary_list_row("Accredited provider", "Best Practice Network")
    expect(page).to have_summary_list_row("Mentors", "James Jameson")

    expect(page).to have_h2("Hours of training")
    expect(page).to have_summary_list_row("James Jameson", "6 hours")

    expect(page).to have_h2("Grant funding")
    expect(page).to have_summary_list_row("Total hours", "6 hours")
    expect(page).to have_summary_list_row("Hourly rate", "£#{@shelbyville_school.region.funding_available_per_hour}")
    expect(page).to have_summary_list_row("Claim amount", "£#{@shelbyville_school.region.funding_available_per_hour * 6}")
  end

  def then_i_see_the_claim_show_page_with_draft_details_and_a_submit_claim_link
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
  end

  def when_i_click_on_accept_and_submit
    click_on "Accept and submit"
  end

  def then_i_see_the_claim_declaration_page
    expect(page).to have_title("Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Claims")
    expect(page).to have_h1("Declaration")
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

    expect(page).to have_warning_text("You will not be able to change any of the claim details once you have submitted the claim.")
    expect(page).to have_button("Accept and submit")
  end

  def then_i_see_the_claim_submitted_page
    expect(page).to have_title("Claim submitted - Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Claims")
    expect(page).to have_element(:h1, class: "govuk-panel__title", text: "Claim submitted")
    expect(page).to have_text("Your reference number")

    expect(page).to have_text("88888888")
    expect(page).to have_text("We have sent a copy of your claim to best_practice_network@example.com")

    expect(page).to have_h2("What happens next")
    expect(page).to have_text("If we need further information to process your claim we will email you.")

    expect(page).to have_h2("We may check your claim")
    expect(page).to have_text("After payment we may check your claim to ensure it is accurate.")

    expect(page).to have_text("Best Practice Network will contact you if your claim undergoes a check.")
  end

  def then_i_see_the_claims_index_page_with_two_submitted_claims
    expect(page).to have_title("Claims - Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Claims")
    expect(page).to have_h1("Claims")
    expect(page).to have_link("Add claim", href: "/schools/#{@shelbyville_school.id}/claims/new")
    expect(page).to have_table_row({
      "Reference" => "12345678",
      "Accredited provider" => "Best Practice Network",
      "Mentors" => "James Jameson",
      "Amount" => "£#{@shelbyville_school.region.funding_available_per_hour * 6}",
      "Date submitted" => @date_completed.strftime("%-d %B %Y").to_s,
      "Status" => "Submitted",
    })
    expect(page).to have_table_row({
      "Reference" => "88888888",
      "Accredited provider" => "Best Practice Network",
      "Mentors" => "James Jameson",
      "Amount" => "£#{@shelbyville_school.region.funding_available_per_hour * 8}",
      "Date submitted" => (@date_completed + 1.day).strftime("%-d %B %Y").to_s,
      "Status" => "Submitted",
    })
  end
end
