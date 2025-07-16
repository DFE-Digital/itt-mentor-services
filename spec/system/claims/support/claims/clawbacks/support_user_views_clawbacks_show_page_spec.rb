require "rails_helper"

RSpec.describe "Support user requests a clawback on a claim", service: :claims, type: :system do
  include ActionView::Helpers::TextHelper

  scenario do
    given_claims_exist
    and_i_am_signed_in

    when_i_navigate_to_the_clawbacks_index_page
    and_i_click_on_claim_with_status_of_claim_not_approved
    then_i_see_the_show_page_for_the_claim_not_approved_claim

    # support user clicks back on show page
    when_i_click_on_back
    then_i_see_the_claims_index_page

    when_i_navigate_to_the_clawbacks_index_page
    and_i_click_on_claim_with_status_of_clawback_requested
    then_i_see_the_show_page_for_the_clawback_requested_claim

    when_i_click_on_change
    then_i_see_the_clawback_step_for_the_clawback_requested_claim

    # support user clicks back on wizard step
    when_i_click_on_back
    then_i_see_the_show_page_for_the_clawback_requested_claim
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

    @mentor = create(:claims_mentor, first_name: "James", last_name: "Chess")

    create(:mentor_training,
           hours_completed: 15,
           claim: @clawback_requested_claim,
           not_assured: true,
           reason_not_assured: "No",
           reason_clawed_back: "Insufficient evidence",
           hours_clawed_back: 2,
           mentor: @mentor)
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
    expect(page).to have_element(:strong, text: "Rejected by school", class: "govuk-tag govuk-tag--turquoise")
    expect(page).to have_link("Request clawback", href: "/support/claims/clawbacks/claims/new/#{@claim_not_approved_claim.id}")
    expect(page).to have_summary_list_row("School", @claim_not_approved_claim.school_name)
    expect(page).to have_summary_list_row("Academic year", @claim_not_approved_claim.academic_year_name)
    expect(page).to have_summary_list_row("Accredited provider", @claim_not_approved_claim.provider_name)
    expect(page).to have_h2("Hours of training")
    @claim_not_approved_claim.mentor_trainings.order_by_mentor_full_name.each do |mentor_training|
      expect(page).to have_summary_list_row(mentor_training.mentor.full_name, "#{mentor_training.hours_completed} hours")
    end
    expect(page).to have_h2("Grant funding")
    expect(page).to have_summary_list_row("Total hours", "#{@claim_not_approved_claim.mentor_trainings.sum(:hours_completed)} hours")
    expect(page).to have_summary_list_row("Claim amount", @claim_not_approved_claim.amount)
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
    expect(page).to have_element(:strong, text: "Ready for clawback", class: "govuk-tag govuk-tag--turquoise")
    expect(page).not_to have_link("Request clawback", href: "/support/claims/clawbacks/claims/new/#{@clawback_requested_claim.id}", class: "govuk-link govuk-button")
    expect(page).to have_summary_list_row("School", @clawback_requested_claim.school_name)
    expect(page).to have_summary_list_row("Academic year", @clawback_requested_claim.academic_year_name)
    expect(page).to have_summary_list_row("Accredited provider", @clawback_requested_claim.provider_name)
    expect(page).to have_h2("Hours of training")
    @clawback_requested_claim.mentor_trainings.not_assured.order_by_mentor_full_name.each do |mentor_training|
      expect(page).to have_element(:dt, text: mentor_training.mentor.full_name, class: "govuk-summary-list__key")
      expect(page).to have_summary_list_row("Original hours claimed", pluralize(mentor_training.hours_completed, "hour"))
      expect(page).to have_summary_list_row("Amount clawed back", pluralize(mentor_training.hours_clawed_back, "hour"))
      expect(page).to have_summary_list_row("Reason for clawback", mentor_training.reason_clawed_back)
    end
    expect(page).to have_h2("Grant funding")
    expect(page).to have_summary_list_row("Original claim amount", @clawback_requested_claim.amount)
    expect(page).to have_summary_list_row("Hours clawed back", pluralize(@clawback_requested_claim.mentor_trainings.sum(:hours_clawed_back), "hour"))
  end

  def when_i_click_on_change
    all("a", text: "Change").last.click
  end

  def then_i_see_the_clawback_step_for_the_clawback_requested_claim
    expect(page).to have_title("Clawback details for #{@mentor.full_name} - #{@clawback_requested_claim.school_name} - Claim 22222222 - Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Claims")

    expect(page).to have_element(:span, text: "Clawbacks - Claim 22222222", class: "govuk-caption-l")
    expect(page).to have_h1("Clawback details")
    expect(page).to have_element(:label, text: "Number of hours to clawback", class: "govuk-label")
    expect(page).to have_element(:div, text: "James Chess' original claim was for 15 hours", class: "govuk-hint")
    expect(page).to have_element(:label, text: "Notes on your decision", class: "govuk-label")
    expect(page).to have_element(:div, text: "Only include details related to #{@mentor.full_name}", class: "govuk-hint")
    expect(page).to have_button("Continue")
    expect(page).to have_link("Cancel", href: "/support/claims/clawbacks/claims/#{@clawback_requested_claim.id}")
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
    expect(page).to have_summary_list_row("Accredited provider", @clawback_in_progress_claim.provider_name)
    expect(page).to have_summary_list_row("Mentors") do |row|
      @clawback_in_progress_claim.mentors.each do |mentor|
        expect(row).to have_css("ul.govuk-list li", text: mentor.full_name)
      end
    end
  end
end
