require "rails_helper"

RSpec.describe "Support user requests a clawback on a claim", service: :claims, type: :system do
  scenario do
    given_claims_exist
    and_i_am_signed_in

    when_i_navigate_to_the_clawbacks_index_page
    and_i_click_on_claim_with_status_of_claim_not_approved
    then_i_see_the_show_page_for_the_claim_not_approved_claim
    and_i_do_not_see_the_clawback_details_section

    # support user clicks back on show page
    when_i_click_on_back
    then_i_see_the_claims_index_page

    when_i_navigate_to_the_clawbacks_index_page
    and_i_click_on_claim_with_status_of_clawback_requested
    then_i_see_the_show_page_for_the_clawback_requested_claim
    and_i_see_the_clawback_details_section

    when_i_click_on_change
    then_i_see_the_clawback_step_for_the_clawback_requested_claim

    # support user clicks back on wizard step
    when_i_click_on_back
    then_i_see_the_clawbacks_index_page

    and_i_click_on_claim_with_status_of_clawback_in_progress
    then_i_see_the_show_page_for_the_clawback_in_progress_claim
    and_i_see_the_clawback_details_section
  end

  private

  def given_claims_exist
    @claim_not_approved_claim = create(:claim,
                                       :submitted,
                                       status: :sampling_not_approved,
                                       reference: 11_111_111)
    @clawback_requested_claim = create(:claim,
                                       :submitted,
                                       status: :clawback_requested,
                                       reference: 22_222_222)
    @clawback_in_progress_claim = create(:claim,
                                         :submitted,
                                         status: :clawback_in_progress,
                                         reference: 33_333_333)
  end

  def and_i_am_signed_in
    sign_in_claims_support_user
  end

  def when_i_navigate_to_the_clawbacks_index_page
    within primary_navigation do
      click_on "Claims"
    end

    within secondary_navigation do
      click_on "Clawbacks"
    end
  end

  def and_i_click_on_claim_with_status_of_claim_not_approved
    click_on "11111111 - #{@claim_not_approved_claim.school_name}"
  end

  def then_i_see_the_show_page_for_the_claim_not_approved_claim
    expect(page).to have_title("Clawbacks - #{@claim_not_approved_claim.school_name} - Claim 11111111 - Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Claims")
    expect(page).to have_element(:span, text: "Clawbacks - Claim 11111111", class: "govuk-caption-l")
    expect(page).to have_h1(@claim_not_approved_claim.school_name)
    expect(page).to have_element(:strong, text: "Claim not approved", class: "govuk-tag govuk-tag--pink")
    expect(page).to have_link("Request clawback", href: "/support/claims/clawbacks/claims/new/#{@claim_not_approved_claim.id}")
    expect(page).to have_summary_list_row("School", @claim_not_approved_claim.school_name)
    expect(page).to have_summary_list_row("Academic year", @claim_not_approved_claim.academic_year_name)
    expect(page).to have_summary_list_row("Accredited provider", @claim_not_approved_claim.provider.name)
    expect(page).to have_summary_list_row("Mentors") do |row|
      @claim_not_approved_claim.mentors.each do |mentor|
        expect(row).to have_css("ul.govuk-list li", text: mentor.full_name)
      end
    end
    expect(page).to have_h2("Hours of training")
    @claim_not_approved_claim.mentor_trainings.order_by_mentor_full_name.each do |mentor_training|
      expect(page).to have_summary_list_row(mentor_training.mentor.full_name, "#{mentor_training.hours_completed} hours")
    end
    expect(page).to have_h2("Grant funding")
    expect(page).to have_summary_list_row("Total hours", "#{@claim_not_approved_claim.mentor_trainings.sum(:hours_completed)} hours")
    expect(page).to have_summary_list_row("Claim amount", @claim_not_approved_claim.amount)
  end

  def and_i_see_the_clawback_details_section
    expect(page).to have_h2("Clawback details")
    expect(page).to have_element(:dt, text: "Number of hours", class: "govuk-summary-list__key")
    expect(page).to have_element(:dt, text: "Hourly rate", class: "govuk-summary-list__key")
    expect(page).to have_element(:dt, text: "Clawback amount", class: "govuk-summary-list__key")
    expect(page).to have_element(:dt, text: "Reason for clawback", class: "govuk-summary-list__key")
    expect(page).to have_element(:dt, text: "Revised claim amount", class: "govuk-summary-list__key")
  end

  def and_i_do_not_see_the_clawback_details_section
    expect(page).not_to have_h2("Clawback details")
    expect(page).not_to have_element(:dt, text: "Reason for clawback", class: "govuk-summary-list__key")
    expect(page).not_to have_element(:dt, text: "Revised claim amount", class: "govuk-summary-list__key")
  end

  def when_i_click_on_back
    click_on "Back"
  end

  def then_i_see_the_claims_index_page
    expect(page).to have_title("Claims - Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Claims")
    expect(secondary_navigation).to have_current_item("All claims")
  end

  def and_i_click_on_claim_with_status_of_clawback_requested
    click_on "22222222 - #{@clawback_requested_claim.school_name}"
  end

  def then_i_see_the_show_page_for_the_clawback_requested_claim
    expect(page).to have_title("Clawbacks - #{@clawback_requested_claim.school_name} - Claim 22222222 - Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Claims")
    expect(page).to have_element(:span, text: "Clawbacks - Claim 22222222", class: "govuk-caption-l")
    expect(page).to have_h1(@clawback_requested_claim.school_name)
    expect(page).to have_element(:strong, text: "Clawback requested", class: "govuk-tag govuk-tag--orange")
    expect(page).not_to have_link("Request clawback", href: "/support/claims/clawbacks/claims/new/#{@clawback_requested_claim.id}", class: "govuk-link govuk-button")
    expect(page).to have_summary_list_row("School", @clawback_requested_claim.school_name)
    expect(page).to have_summary_list_row("Academic year", @clawback_requested_claim.academic_year_name)
    expect(page).to have_summary_list_row("Accredited provider", @clawback_requested_claim.provider.name)
    expect(page).to have_summary_list_row("Mentors") do |row|
      @clawback_requested_claim.mentors.each do |mentor|
        expect(row).to have_css("ul.govuk-list li", text: mentor.full_name)
      end
    end
    expect(page).to have_h2("Hours of training")
    @clawback_requested_claim.mentor_trainings.order_by_mentor_full_name.each do |mentor_training|
      expect(page).to have_summary_list_row(mentor_training.mentor.full_name, "#{mentor_training.hours_completed} hours")
    end
    expect(page).to have_h2("Grant funding")
    expect(page).to have_summary_list_row("Total hours", "#{@clawback_requested_claim.mentor_trainings.sum(:hours_completed)} hours")
    expect(page).to have_summary_list_row("Claim amount", @clawback_requested_claim.amount)
  end

  def when_i_click_on_change
    all("a", text: "Change").last.click
  end

  def then_i_see_the_clawback_step_for_the_clawback_requested_claim
    # TODO: Add expectation for prepopulated fields with expected values.
    expect(page).to have_title("Clawback details - #{@clawback_requested_claim.school_name} - Claim 22222222 - Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Claims")

    expect(page).to have_element(:span, text: "Clawbacks - Claim 22222222", class: "govuk-caption-l")
    expect(page).to have_h1("Clawback details")
    expect(page).to have_element(:label, text: "Number of hours to clawback", class: "govuk-label")
    expect(page).to have_element(:div, text: "Enter whole numbers up to a maximum of 40 hours", class: "govuk-hint")
    expect(page).to have_element(:label, text: "Reason for clawback", class: "govuk-label")
    expect(page).to have_element(:div, text: "Explain why the clawback is being requested. For example, include details of which mentor has received a deduction.", class: "govuk-hint")
    expect(page).to have_button("Continue")
    expect(page).to have_link("Cancel", href: "/support/claims/clawbacks/claims")
  end

  def then_i_see_the_clawbacks_index_page
    expect(page).to have_title("Claims - Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Claims")
    expect(secondary_navigation).to have_current_item("Clawbacks")
  end

  def and_i_click_on_claim_with_status_of_clawback_in_progress
    click_on "33333333 - #{@clawback_in_progress_claim.school_name}"
  end

  def then_i_see_the_show_page_for_the_clawback_in_progress_claim
    expect(page).to have_title("Clawbacks - #{@clawback_in_progress_claim.school_name} - Claim 33333333 - Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Claims")
    expect(page).to have_element(:span, text: "Clawbacks - Claim 33333333", class: "govuk-caption-l")
    expect(page).to have_h1(@clawback_in_progress_claim.school_name)
    expect(page).to have_element(:strong, text: "Clawback in progress", class: "govuk-tag govuk-tag--orange")
    expect(page).not_to have_link("Request clawback", href: "/support/claims/clawbacks/claims/new/#{@clawback_in_progress_claim.id}", class: "govuk-link govuk-button")
    expect(page).to have_summary_list_row("School", @clawback_in_progress_claim.school_name)
    expect(page).to have_summary_list_row("Academic year", @clawback_in_progress_claim.academic_year_name)
    expect(page).to have_summary_list_row("Accredited provider", @clawback_in_progress_claim.provider.name)
    expect(page).to have_summary_list_row("Mentors") do |row|
      @clawback_in_progress_claim.mentors.each do |mentor|
        expect(row).to have_css("ul.govuk-list li", text: mentor.full_name)
      end
    end
  end
end
