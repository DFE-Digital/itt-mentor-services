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

    when_i_navigate_to_the_clawbacks_index_page
    and_i_click_on_claim_with_status_of_clawback_in_progress
    then_i_see_the_show_page_for_the_clawback_in_progress_claim
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
    @colin = build(:claims_support_user, :colin)
    create(:mentor_training,
           hours_completed: 15,
           claim: @clawback_requested_claim,
           not_assured: true,
           reason_not_assured: "No",
           reason_clawed_back: "Insufficient evidence",
           hours_clawed_back: 2,
           mentor: @mentor)
    @clawback_requested_activity_log = create(:claim_activity, :clawback_requested, user: @colin, record: @clawback_requested_claim)
    @clawback = build(:clawback, claims: [@clawback_in_progress_claim])
    @clawback_response_uploaded_activity_log = create(:claim_activity, :clawback_response_uploaded, user: @colin, record: @clawback)
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
      within(".govuk-summary-card") do
        expect(page).to have_element(:div, text: mentor_training.mentor.full_name, class: "govuk-summary-card__title-wrapper")
        within(".govuk-summary-card__content") do
          expect(page).to have_summary_list_row("Mentor worked hours", pluralize(mentor_training.corrected_hours_completed, "hour"))
          expect(page).to have_summary_list_row("Original hours claimed", pluralize(mentor_training.hours_completed, "hour"))
          expect(page).to have_summary_list_row("Hours clawed back", pluralize(mentor_training.hours_clawed_back, "hour"))
          expect(page).to have_summary_list_row("Reason for clawback", mentor_training.reason_clawed_back)
        end
      end
    end

    within("#grant_funding") do
      expect(page).to have_h2("Grant funding")
      expect(page).to have_summary_list_row("Original claim amount", @clawback_requested_claim.amount)
      expect(page).to have_summary_list_row("Hours clawed back", pluralize(@clawback_requested_claim.mentor_trainings.sum(:hours_clawed_back), "hour"))
    end

    expect(page).to have_h2("Grant funding")
    expect(page).to have_summary_list_row("Original claim amount", @clawback_requested_claim.amount)
    expect(page).to have_h2("History")
    expect(page).to have_element("h3", class: "app-timeline__title", text: "Clawback requested for claim 22222222")
    expect(page).to have_link("View details", href: claims_support_claims_claim_activity_path(@clawback_requested_activity_log))
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
    expect(page).to have_element(:strong, text: "Sent to payer for clawback", class: "govuk-tag govuk-tag--yellow")
    expect(page).not_to have_link("Request clawback", href: "/support/claims/clawbacks/claims/new/#{@clawback_in_progress_claim.id}", class: "govuk-link govuk-button")
    expect(page).to have_summary_list_row("School", @clawback_in_progress_claim.school_name)
    expect(page).to have_summary_list_row("Academic year", @clawback_in_progress_claim.academic_year_name)
    expect(page).to have_summary_list_row("Accredited provider", @clawback_in_progress_claim.provider_name)
    expect(page).to have_summary_list_row("Mentors") do |row|
      @clawback_in_progress_claim.mentors.each do |mentor|
        expect(row).to have_css("ul.govuk-list li", text: mentor.full_name)
      end
    end
    expect(page).to have_h2("History")
    expect(page).to have_element("h3", class: "app-timeline__title", text: "Payer clawback response uploaded for 1 claim")
    expect(page).to have_link("View details", href: claims_support_claims_claim_activity_path(@clawback_response_uploaded_activity_log))
  end
end
